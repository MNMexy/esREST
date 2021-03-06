﻿function New-ESRole {
	<#
		.SYNOPSIS
			Generates a new esRest.Role object
		.DESCRIPTION
			Generates an object that represents an ElasticSearch role from the "native" realm. Should be used with Set-ESRole when creating new roles.
		.PARAMETER Name
			The name of the role
		.PARAMETER ClusterPrivilege
			One or more values to be assigned to this role. Must be members of the esRest.ClusterPrivilege enumeration.
		.PARAMETER IndexPrivilegeGroup
			One or more esRest.IndexPrivilegeGroup objects generated by the New-ESIndexPrivilegeGroup function.
		.PARAMETER RunAs
			The name of one or more users that this role will be able to submit requests on the behalf of.
		.EXAMPLE
			C:\PS> $newRole = New-ESRole -Name cluster_admin -Cluster all
			C:\PS> Set-ESRole -Role $newRole -BaseURI http://some.escluster.com:1234 -Credential (Get-Credential)
			
			Creates a new role called "cluster_admin" with "all" cluster privileges.
		.EXAMPLE
			C:\PS> $newPrivGroup = New-ESIndexPrivilegeGroup -Index "thing","stuff" -Priviledge read
			C:\PS> $someRole = New-ESRole -Name some_index_read -IndexPrivilegeGroup $newPrivGroup
			C:\PS> Set-ESRole -Role $someRole -BaseURI http://some.escluster.com:1234 -Credential (Get-Credential)
			
			Creates a new role called "some_index_read" with read acces to the "thing" and "stuff" indices.
		.LINK
			https://www.elastic.co/guide/en/shield/current/configuring-rbac.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Name,
		
		[esREST.IndexPrivilegeGroup[]]$IndexPrivilegeGroup,
		
		[string[]]$RunAs
	)
    DynamicParam {
		# Generate the Privilege parameter
		$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		
		$ParameterName = 'ClusterPrivilege'
		$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		$ParameterAttribute.Mandatory = $Mandatory
		$ParameterAttribute.Position = 1
		$AttributeCollection.Add($ParameterAttribute)

		# Set the ValidateSet
		$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute( [enum]::GetValues( [type]'esREST.ClusterPrivilege') )
		$AttributeCollection.Add($ValidateSetAttribute)
		
		$RuntimeParameterDictionary.Add( $ParameterName, ( New-Object System.Management.Automation.RuntimeDefinedParameter( $ParameterName, [string[]], $AttributeCollection ) ) )
		return $RuntimeParameterDictionary
    }
	Begin {
		$ClusterPrivilege = $PsBoundParameters['ClusterPrivilege']
	}
	Process {
		$result = New-Object -TypeName esREST.Role -Property @{ Name = $Name; ClusterPrivilege = $ClusterPrivilege; IndexPrivilegeGroup = $IndexPrivilegeGroup; RunAs = $RunAs }
		Write-Output $result
	}
}
