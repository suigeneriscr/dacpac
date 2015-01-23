#
# Author:: Alfonso Aguilar (<luis.aguilar@suigeneris.com>)
# Cookbook Name:: dacpac
# Resource:: deploy
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

action :deploy do

  Chef::Log.info("Deploy of #{@new_resource.name} has started")

  script =<<-EOF
    $exitVal=0
    function deployDatabase{ param([string]$dacDllPath, [string]$publishFilePath, [string]$connectionString, [string]$dacFilePath, [string]$databaseName)
      try{
        # load Dac Pac
        add-type -path $dacDllPath

        #Read a publish profile XML to get the deployment options
        $dacProfile = [Microsoft.SqlServer.Dac.DacProfile]::Load($publishFilePath)

        # make DacServices object, needs a connection string 
        $dacServices = new-object Microsoft.SqlServer.Dac.DacServices $connectionString

        # register event. For info on this cmdlet, see http://technet.microsoft.com/en-us/library/hh849929.aspx 
        register-objectevent -in $dacServices -eventname Message -source "msg" -action { out-host -in $Event.SourceArgs[1].Message.Message } | Out-Null

        # Load dacpac from file & deploy to database named pubsnew 
        #eXigoSFO 
        $dacServices.Deploy([Microsoft.SqlServer.Dac.DacPackage]::Load($dacFilePath), $databaseName, $true, $dacProfile.DeployOptions)

        # clean up event 
        unregister-event -source "msg"
        $exitVal = 2
      }
      catch
      {
        $message = \"Deploy Error - \";
        $message += $_;
        $exitVal=1;
      }
      write-host $message;
      exit $exitVal;
    }

    deployDatabase "'#{ENV['ProgramFiles(x86)']}\\Microsoft SQL Server\\110\\DAC\\bin\\Microsoft.SqlServer.Dac.dll'" "'#{@new_resource.publish_file_path}'" "'#{@new_resource.connection_string}'" "'#{@new_resource.path}'" "'#{@new_resource.database_name}'"
  EOF

  result = powershell_out(script)
 
  # same as shell_out
  if result.exitstatus == 2
    Chef::Log.info("Deploy successfull of #{@new_resource.name} in the database #{@new_resource.database_name} : #{result.stdout}")
  else
    Chef::Log.error("Deploy of #{@new_resource.name} in the database #{@new_resource.database_name} failed with error :  #{result.stdout} #{result.stderr}")
    # any other actions here?  maybe flag the node?
  end
end