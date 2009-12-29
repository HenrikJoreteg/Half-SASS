<?xml version="1.0" encoding="UTF-8"?>
<transfer xsi:noNamespaceSchemaLocation="transfer.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <objectDefinitions>
		<package name="security">
			<!-- User -->
			<object name="User" table="Users" decorator="FormDaddyDev.model.security.User">
				<id name="UserID"              type="UUID" generate="true"/>
				<property name="icasID"        type="string" />
                <property name="fname"         type="string" />
				<property name="lname"         type="string" />
				<property name="email"         type="string" />
				<property name="isSuperUser"   type="boolean" />
			</object>
		</package>
   	</objectDefinitions>
</transfer>