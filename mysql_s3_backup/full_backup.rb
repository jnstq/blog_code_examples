#!/usr/bin/env ruby

require "common"

FileUtils.mkdir_p @temp_dir
begin
  [@mysql_database].flatten.each do |database|
    dump_file = "#{@temp_dir}/#{database}.dump.sql.gz"

    cmd = "mysqldump -u#{@mysql_user}"
    cmd += " -p'#{@mysql_password}'" unless @mysql_password.nil?
    cmd += " #{database} | gzip > #{dump_file}"
    run(cmd)

    AWS::S3::S3Object.store(File.basename(dump_file), open(dump_file), @s3_bucket)
  end
ensure
  FileUtils.rm_rf(@temp_dir)
end
