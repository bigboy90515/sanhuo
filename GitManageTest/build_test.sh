#!/bin/bash

#计时
SECONDS=0

#假设脚本放置在与项目相同的路径下
project_path=$(pwd)
#取当前时间字符串添加到文件结尾
now=$(date +"%Y_%m_%d_%H_%M_%S")

#指定项目的scheme名称 Default:GWMovie 1:GWMovieInHouse
scheme="GitManageTest"
if [$1 = ""]; then
  echo "scheme default"
else
  scheme=$1
fi
#指定要打包的配置名 Default:Release 1:Debug 2:Adhoc
configuration="Release"
if [$1 != ""]; then
  echo "configuration default"
else
  configuration=$2
fi

export_method='ad-hoc'

#指定打包所使用的provisioning profile名称
provisioning_profile='iPhone Distribution: Shanghai Lubao Network Technology Co., Ltd. (HZ27GD3B7H)'

#指定项目地址
workspace_path="$project_path/GitManageTest.xcodeproj"
#指定输出路径
output_path="/Users/Shared/Jenkins/Desktop/archive"
#指定输出归档文件地址
archive_path="$output_path/GitManageTest_${now}.xcarchive"
#指定输出ipa地址
ipa_path="$output_path/GitManageTest_${now}.ipa"
#指定输出ipa名称
ipa_name="GitManageTest_${now}.ipa"
#获取执行命令时的commit message
commit_msg="$1"
#fir token
fir_token="63e91a160839c7fb15dcd00c99542e29"

#xcodebuild clean
#xcodebuild -project GitManageTest.xcodeproj -scheme GitManageTest -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' test | xcpretty -s   -tc
#xcodebuild -project GitManageTest.xcodeproj -scheme GitManageTest run-tests

#xctool -project GitManageTest.xcodeproj -scheme GitManageTestTests test
#test

#xcodebuild -project Carthage-Realm.xcodeproj -scheme Carthage-Realm -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' clean build test | tee $CIRCLE_ARTIFACTS/xcode_raw.log | xcpretty --color --report junit --output $CIRCLE_TEST_REPORTS/xcode/results.xml

#xcodebuild -project GitManageTest.xcodeproj -scheme GitManageTest test | tee xcodebuild.log | xcpretty -t -r html --output ~/Desktop/aaaaaaaa.html



#输出设定的变量值
echo "===workspace aaaaa path: ${workspace_path}==="
echo "===archive path: ${archive_path}==="
echo "===ipa path: ${ipa_path}==="
echo "===profile: ${provisioning_profile}==="
echo "===commit msg: ${commit_msg}==="

fastlane gym --project ${workspace_path} --scheme ${scheme} -clean --configuration ${configuration} --archive_path ${archive_path} --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}

echo "===build ipa success==="
echo "===start upload to fir ==="

fir publish ${ipa_path} -T "${fir_token}" -c "${commit_msg}"

echo "===upload to fir success==="

rm -rf ${output_path}

#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="
