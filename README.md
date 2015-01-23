Description
===========

Provides database tools for deploy Visual Studio database projects. Use the DacServices tools of the SQL Server Data Tools package

Requirements
============

Platform
--------

* Windows 7
* Windows 8
* Windows Server 2008 (R1, R2)
* Windows Server 2012
* Windows Server 2012R2

Cookbooks
---------

* dacpac

Attributes
==========


Resource/Provider
=================

dacpac_deploy
---------

Deploys a dacpac file to a database.

### Actions

- `:deploy` - deploy a dac package to a database.

### Attribute Parameters

- `name` - name attribute. Name of the process to be executed.
- `path` - path of the dacpac file.
- `connection_string` - SQL Server connection string. Example:  "Data Source=localhost;User ID=sa;Password=***;"
- `database_name` - name of the database where the dacpac file will be deployed
- `publish_file_path` - path of the XML file that contains the deploy options. It could be in the cookbook files subdir, use the cookbook_file resource to extract it.

### Examples

    # deploy a dacpac file
    dacpac_deploy "AdventureWorks" do
      path  "C:\\chef\chef_cache\\dacpac\\AdventureWorks.dacpac"
      connection_string "Data Source=localhost;User ID=sa;Password=***;"
      database_name "AdventureWorks"
      publish_file_path "C:\\chef\chef_cache\\dacpac\\database-deploy-options.xml"
      action :deploy
    end

dacpac_backup
---------

Backup a database using SQL Server Full backup method.

### Actions

- `:backup` - Makes a backup of a SQL Server database.

### Attribute Parameters

attribute :instance, :kind_of => String
attribute :login, :kind_of => String
attribute :password, :kind_of => String
attribute :database_name, :kind_of => String
attribute :path, :kind_of => String

- `name` - name attribute. Name of the process to be executed.
- `path` - path where the backup file will be stored.
- `login` - user name of the database
- `login` - user name of the database
- `password` - password of the user to login
- `database_name` - name of the database where the dacpac file will be deployed

### Examples

    # backup a SQL Server database
    now = Time.now.strftime("%Y%m%d%H%M%S")
    database_name = "AdventureWorks"
	dacpac_backup "AdventureWorks" do
	  path  "C:\\DATABASES\\BACKUP\\#{database_name}_#{now}.bak"
	  instance "localhost"
	  login "sa"
	  password "***"
	  database_name "#{database_name}"
	  action :backup
	end

License and Author
==================

* Author:: Alfonso Aguilar (<luis.aguilar@suigeneris.com>)

Copyright:: 2015, SuiGeneris S.A.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
