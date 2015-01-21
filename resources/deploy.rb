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

actions :deploy, :generate

attribute :name, :kind_of => String, :name_attribute => true
attribute :path, :kind_of => String
attribute :connection_string, :kind_of => String
attribute :database_name, :kind_of => String
attribute :publish_file_path, :kind_of => String

def initialize(*args)
  super
  @action = :deploy
end
