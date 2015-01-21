Description
===========

Deploy Microsoft Visual Studio database project using DacServices of the SQL Server Data Tools

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

attribute :name, :kind_of => String, :name_attribute => true
attribute :path, :kind_of => String
attribute :connection_string, :kind_of => String
attribute :database_name, :kind_of => String
attribute :publish_file_path, :kind_of => String

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
