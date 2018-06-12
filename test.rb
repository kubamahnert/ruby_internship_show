load 'connection_opts.rb'

client = GoodData.connect *connection_opts
project = create_simple_project 'internship_test', client, proj_token

data = CSV.read 'commit_data.csv'
blueprint = project.blueprint
project.upload data, blueprint, 'commits'
a = 5