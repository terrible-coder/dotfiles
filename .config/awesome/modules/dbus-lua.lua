local lgi = require("lgi")
GLib, Gio = lgi.GLib, lgi.Gio

local Bus = { }

setmetatable(Bus, {
	__index = function(t, k)
		if k == "SYSTEM" or k == "SESSION" then
			return Gio.bus_get_sync(Gio.BusType[k])
		end
		if type(k) == "string" then
			t[k] = Gio.DBusConnection.new_for_address_sync(
				k, Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT, nil
			)
			return t[k]
		end
	end
})

local Variant = { }

function Variant.params(method, ...)
	local parameters = { ... }
	local children = { }
	for i, arg in ipairs(method.in_args) do
		children[i] = GLib.Variant.new(arg.signature, parameters[i])
	end
	return GLib.Variant.new_tuple(children)
end

function Variant.unpack(variant)
	if not tostring(variant):match("GLib%.Variant$") then
		return variant
	end
	if variant:is_of_type(GLib.VariantType.VARIANT) then
		return Variant.unpack(variant.value)
	end
	if variant:is_container() then
		local result = { }
		if variant:is_of_type(GLib.VariantType.DICTIONARY) then
			for i = 1, variant:n_children() do
				local child = variant:get_child_value(i-1)
				result[child[1]] = Variant.unpack(child[2])
			end
		else
			for i = 1, variant:n_children() do
				result[i] = Variant.unpack(variant:get_child_value(i-1))
			end
		end
		return result
	end
	return variant.value
end

local DEFAULT_TIMEOUT = -1
local introspection_type = GLib.VariantType.new("(s)")

local Proxy = { }
function Proxy.generate_sync_method(proxy, method)
	return function(self, ...)
		local result = Variant.unpack(proxy:call_sync(
		method.name,
		Variant.params(method, ...),
		Gio.DBusCallFlags.NONE,
		DEFAULT_TIMEOUT
		))
		if #result == 1 then
			return result[1]
		end
		return result
	end
end
function Proxy.generate_async_method(proxy, method)
	return function(self, callback, user_data, ...)
		proxy:call(
			method.name,
			Variant.params(method, ...),
			Gio.DBusCallFlags.NONE,
			DEFAULT_TIMEOUT,
			nil,
			function(source_obj, res)
				local result, err = source_obj:call_finish(res)
				if not result and err then
					callback(user_data, result, err)
					return
				end
				result = Variant.unpack(result)
				if #result == 1 then
					callback(user_data, result[1])
				else
					callback(user_data, result)
				end
			end,
			nil
		)
	end
end
function Proxy.generate_property(proxy, property)
	return Variant.unpack(proxy:get_cached_property(property.name))
end

function Proxy.new(obj, iface)
	local iface_info = obj.info:lookup_interface(iface)
	if not iface_info then
		local msg = "Interface '%s' not implemented by object %s"
		error(msg:format(iface, obj.object_path))
	end
	local proxy = Gio.DBusProxy.new_sync(
		obj.connection,
		Gio.DBusProxyFlags.NONE,
		iface_info,
		obj.name,
		obj.object_path,
		iface
	)
	local p = {
		object_path = obj.object_path,
		interface = iface,
	}
	for _, method in ipairs(iface_info.methods) do
		p[method.name] = Proxy.generate_sync_method(proxy, method)
		p[method.name.."Async"] = Proxy.generate_async_method(proxy, method)
	end
	local meta_call = {
		__call = function(tbl, callback)
			table.insert(tbl, callback)
		end
	}
	p.on = { }
	for _, signal in ipairs(iface_info.signals) do
		p.on[signal.name] = setmetatable({ }, meta_call)
	end
	p.on.PropertiesChanged = setmetatable({ }, meta_call)
	function proxy:on_g_signal(sender, signal, params)
		-- if sender ~= obj.name then return end
		for _, handler in ipairs(p.on[signal]) do
			handler(table.unpack(Variant.unpack(params)))
		end
	end
	function proxy:on_g_properties_changed(changed, invalidated)
		for _, prop_handler in ipairs(p.on.PropertiesChanged) do
			prop_handler(Variant.unpack(changed), invalidated)
		end
	end
	function p.on.destroy()
		for _, signal in ipairs(iface_info.signals) do
			p.on[signal.name] = setmetatable({ }, meta_call)
		end
		p.on.PropertiesChanged = setmetatable({ }, meta_call)
	end
	return setmetatable(p, {
		__index = function(_, key)
			return Variant.unpack(proxy:get_cached_property(key))
		end
	})
end

local ObjectProxy = { }
ObjectProxy.__index = ObjectProxy
function ObjectProxy:implement(iface)
	return Proxy.new(self, iface)
end
function ObjectProxy.new(connection, path, name)
	local introspection, err = connection:call_sync(
		name, path,
		"org.freedesktop.DBus.Introspectable", "Introspect",
		nil, introspection_type,
		Gio.DBusCallFlags.NONE,
		DEFAULT_TIMEOUT
	)
	if err then
		error(err)
	end
	local xml_data = introspection.value[1]
	local node = Gio.DBusNodeInfo.new_for_xml(xml_data)
	local o = {
		connection = connection,
		object_path = path,
		name = name,
		info = node
	}
	return setmetatable(o, ObjectProxy)
end

return {
	Bus = Bus,
	Variant = Variant,
	ObjectProxy = ObjectProxy,
	Proxy = Proxy,
}
