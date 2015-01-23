#
# Author:: Alfonso Aguilar (<luis.aguilar@suigeneris.com>)
# Cookbook Name:: dacpac
# Resource:: backup
#
# Copyright:: 2015, SuiGeneris, S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'

include Chef::Mixin::ShellOut
include Chef::Mixin::PowershellOut

action :backup do

  Chef::Log.info("Backup of #{@new_resource.name} has started")

  script =<<-EOF
    $exitVal=0
    function backupDatabase{ param([string]$ssAsmPath, [string]$instance, [string]$login, [string]$password, [string]$databaseName, [string]$path)
      try{
        Add-Type -Path ($ssAsmPath + '\\Microsoft.SqlServer.Smo.dll')
        Add-Type -Path ($ssAsmPath + '\\Microsoft.SqlServer.SmoExtended.dll')
        
        # Prepare database connection
        $svr = New-Object 'Microsoft.SqlServer.Management.SMO.Server' $instance 
        $svr.ConnectionContext.LoginSecure = $false
        $svr.ConnectionContext.Login = $login
        $svr.ConnectionContext.Password = $password
        $bdir = $svr.Settings.BackupDirectory
        $db = $svr.Databases[$databaseName]
        $dbname = $db.Name
        
        # Setup the backup object
        $dbbk = new-object ('Microsoft.SqlServer.Management.Smo.Backup')
        $dbbk.Action = 'Database'
        $dbbk.BackupSetDescription = 'Full backup of ' + $dbname
        $dbbk.BackupSetName = $dbname + ' Backup'
        $dbbk.Database = $dbname
        $dbbk.MediaDescription = 'Disk'
        $dbbk.Devices.AddDevice($path, 'File')
        # Execute the backup process
        $dbbk.SqlBackup($svr)
        $exitVal = 2
        $message = $path
      }
      catch{
        $message = 'Backup Error - ';
            $message += $_;
            $exitVal=1;
      }
      write-host $message;
      exit $exitVal;
    }


    backupDatabase "'#{ENV['ProgramFiles(x86)']}\\Microsoft SQL Server\\110\\SDK\\Assemblies'" "'#{@new_resource.instance}'" "'#{@new_resource.login}'" "'#{@new_resource.password}'" "'#{@new_resource.database_name}'" "'#{@new_resource.path}'"
  EOF

  result = powershell_out(script)
 
  # same as shell_out
  if result.exitstatus == 2
    Chef::Log.info("Backup of #{@new_resource.database_name} was successfull : #{result.stdout}")
  else
    Chef::Log.error("Backup of #{@new_resource.database_name} failed with error :  #{result.stdout} #{result.stderr}")
    # any other actions here?  maybe flag the node?
  end
end