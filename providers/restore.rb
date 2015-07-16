#
# Author:: Alfonso Aguilar (<luis.aguilar@suigeneris.com>)
# Cookbook Name:: dacpac
# Resource:: restore
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

action :restore do

  Chef::Log.info("Restore of #{@new_resource.name} has started")

  script =<<-EOF
    $exitVal=0
    function restoreDatabase{ param([string]$ssAsmPath, [string]$instance, [string]$login, [string]$password, [string]$databaseName, [string]$path)
      try{
        Add-Type -Path ($ssAsmPath + '\\Microsoft.SqlServer.Smo.dll')
        Add-Type -Path ($ssAsmPath + '\\Microsoft.SqlServer.SmoExtended.dll')
        
        # Prepare database connection
        $svr = New-Object 'Microsoft.SqlServer.Management.SMO.Server' $instance 
        $svr.ConnectionContext.LoginSecure = $false
        $svr.ConnectionContext.Login = $login
        $svr.ConnectionContext.Password = $password

        # Get the default file and log locations
        # (If DefaultFile and DefaultLog are empty, use the MasterDBPath and MasterDBLogPath values)
        $fileloc = $svr.Settings.DefaultFile
        $logloc = $svr.Settings.DefaultLog
        if ($fileloc.Length -eq 0) {
          $fileloc = $svr.Information.MasterDBPath
        }
        if ($logloc.Length -eq 0) {
          $logloc = $svr.Information.MasterDBLogPath
        }

        # Use the backup file name to create the backup device
        $bdi = new-object ('Microsoft.SqlServer.Management.Smo.BackupDeviceItem') ($path, 'File')

        # Create the new restore object, set the database name and add the backup device
        $rs = new-object('Microsoft.SqlServer.Management.Smo.Restore')
        $rs.Database = $databaseName
        $rs.Devices.Add($bdi)
        $rs.FileNumber = 1

        # Get the file list info from the backup file
        $fl = $rs.ReadFileList($svr)
        $dCounter = 0;
        $lCounter = 0;
        foreach ($fil in $fl) {
          $rsfile = new-object('Microsoft.SqlServer.Management.Smo.RelocateFile')
          $rsfile.LogicalFileName = $fil.LogicalName
          if ($fil.Type -eq 'D'){
            if($dCounter -eq 0){
              $rsfile.PhysicalFileName = $fileloc + '\\'+ $databaseName + '.mdf'
            }else{
              $rsfile.PhysicalFileName = $fileloc + '\\'+ $databaseName + '_' + $dCounter + '.ndf'
            }
            $dCounter++;
          }
          else {
            if($lCounter -eq 0){
              $rsfile.PhysicalFileName = $logloc + '\\'+ $databaseName + '.ldf'
            }else{
              $rsfile.PhysicalFileName = $logloc + '\\'+ $databaseName + '_' + $lCounter + '.ldf'
            }
            $lCounter++;
          }
          $rs.RelocateFiles.Add($rsfile)
        }

        # Restore the database
        $rs.SqlRestore($svr)

        $exitVal = 2
        $message = $path
      }
      catch{
        $message = 'Restore Error - ';
            $message += $_;
            $message += $_.Exception.GetBaseException().Message;
            $exitVal=1;
      }
      write-host $message;
      exit $exitVal;
    }


    restoreDatabase "'#{ENV['ProgramFiles(x86)']}\\Microsoft SQL Server\\100\\SDK\\Assemblies'" "'#{@new_resource.instance}'" "'#{@new_resource.login}'" "'#{@new_resource.password}'" "'#{@new_resource.database_name}'" "'#{@new_resource.path}'"
  EOF

  result = powershell_out(script)
 
  # same as shell_out
  if result.exitstatus == 2
    Chef::Log.info("Restore of #{@new_resource.database_name} was successfull : #{result.stdout}")
  else
    Chef::Log.error("Restore of #{@new_resource.database_name} failed with error :  #{result.stdout} #{result.stderr}")
    # any other actions here?  maybe flag the node?
  end
end