<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldbox.org/schema/config_3.0.0.xsd">
	<Settings>
		<Setting name="AppName"						value="FormDaddyDev"/>
		<Setting name="AppMapping"					value="/FormDaddyDev"/>      
		<Setting name="DebugMode" 					value="true" />
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="ReinitPassword" 				value=""/>
		<Setting name="DefaultEvent" 				value="general.index"/>
		<Setting name="RequestStartHandler" 		value="main.onRequestStart"/>
		<Setting name="ApplicationStartHandler" 	value="main.onAppInit"/>
		<Setting name="onInvalidEvent" 				value="" />
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<Setting name="ConfigAutoReload"          	value="false" />
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="EventCaching" 				value="false"/>
	</Settings>

	<YourSettings>
		<Setting name="FormDaddy_ConfigFile"    value="${AppMapping}/plugins/formdaddy/test/Forms.cfm" />
	</YourSettings>
	
	<DebuggerSettings>
		<PersistentRequestProfiler>true</PersistentRequestProfiler>
		<maxPersistentRequestProfilers>10</maxPersistentRequestProfilers>
		<maxRCPanelQueryRows>50</maxRCPanelQueryRows>
		
		<TracerPanel 	show="true" expanded="true" />
		<InfoPanel 		show="true" expanded="true" />
		<CachePanel 	show="true" expanded="false" />
		<RCPanel		show="true" expanded="false" />
	</DebuggerSettings>
		
	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<Interceptors>
		<Interceptor class="coldbox.system.interceptors.Autowire" />		
	</Interceptors>
	
</Config>

