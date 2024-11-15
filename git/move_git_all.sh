#!/bin/bash

# 迁移git脚本
# 迁移群组、项目、帐号、项目权限
# 如果存在超大仓库 迁移导入会存在失败情况
# 部分查询会涉及到分页查询，需要设置分页大小

# 配置变量
OLD_GITLAB_URL="https://xx"
NEW_GITLAB_URL="http://xx"
OLD_GITLAB_TOKEN="xx"  # 旧 GitLab 实例的访问令牌
NEW_GITLAB_TOKEN="xx"  # 新 GitLab 实例的访问令牌
EXPORT_DIR="./gitlab_exports"         # 存放导出文件的目录
LOG_FILE="./sync_git.log"             # 日志文件

echo "开始进行Gitlab迁移操作. 迁移源:${OLD_GITLAB_URL} 迁移目标:${NEW_GITLAB_URL}"

# 创建导出目录
mkdir -p $EXPORT_DIR
# 创建日志文件
echo "GitLab迁移日志 - $(date)" >> $LOG_FILE

echo "开始群组数据迁移...."
# 获取所有群组的 ID、名称和路径
group_info=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/groups?page=1&per_page=100" | jq -c '.[] | {id: .id, name: .name, path: .path}')
# 遍历每个群组，执行导出、检查状态并下载
echo "$group_info" | while IFS= read -r group; do
    group_id=$(echo "$group" | jq -r '.id')
    group_name=$(echo "$group" | jq -r '.name')
    group_path=$(echo "$group" | jq -r '.path')

    echo "导出群组 ID: $group_id, 名称: $group_name, 路径: $group_path" >> $LOG_FILE

    # 触发群组导出
    curl --silent --request POST --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/groups/$group_id/export"
	sleep 5
done
echo "群组数据请求导出中.... 等待10s..."

 等待导出完成
sleep 10
echo "开始下载并导入群组数据到新的Gitlab中...."
# 下载导出文件并导入到新 GitLab 实例
echo "$group_info" | while IFS= read -r group; do
    group_id=$(echo "$group" | jq -r '.id')
    group_name=$(echo "$group" | jq -r '.name')
    group_path=$(echo "$group" | jq -r '.path')

    # 下载导出文件
    echo "下载群组 $group_id 的导出文件..."  >> $LOG_FILE
    curl --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" -o "$EXPORT_DIR/group_$group_id.tar.gz" "$OLD_GITLAB_URL/api/v4/groups/$group_id/export/download"
    echo "群组 $group_id 导出完成，已下载文件到 $EXPORT_DIR/group_$group_id.tar.gz"  >> $LOG_FILE

    # 将群组导入到新 GitLab 实例
    echo "导入群组 ID: $group_id 到新 GitLab 实例..."  >> $LOG_FILE
    curl --silent --request POST --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" \
        --form "name=$group_name" --form "path=$group_path" --form "file=@$EXPORT_DIR/group_$group_id.tar.gz" \
        "$NEW_GITLAB_URL/api/v4/groups/import"
    echo "群组 $group_id 导入完成。"  >> $LOG_FILE
	sleep 5
done
echo "所有群组导出和导入操作已完成。"  >> $LOG_FILE

echo "开始项目数据迁移...."
# 获取所有项目的 ID、名称和路径
project_info=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/projects?page=1&per_page=100" | jq -c '.[] | {id: .id, name: .name, path: .path, namespace: .namespace.name}')
# 遍历每个项目，执行导出、检查状态并下载
echo "$project_info" | while IFS= read -r project; do
    project_id=$(echo "$project" | jq -r '.id')
    project_name=$(echo "$project" | jq -r '.name')
    project_path=$(echo "$project" | jq -r '.path')

    echo "导出项目 ID: $project_id, 名称: $project_name, 路径: $project_path"  >> $LOG_FILE
    # 触发项目导出
    curl --silent --request POST --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/projects/$project_id/export"
	# 等待导出完成
	sleep 10
done
echo "导出项目请求完成.... 等待Gitlab处理.... 等待5分钟...."
sleep 30

echo "开始下载并导入项目数据到新的Gitlab中...."
# 下载导出文件并导入到新 GitLab 实例
echo "$project_info" | while IFS= read -r project; do
    project_id=$(echo "$project" | jq -r '.id')
    project_name=$(echo "$project" | jq -r '.name')
    project_path=$(echo "$project" | jq -r '.path')
    namespace=$(echo "$project" | jq -r '.namespace')

    if [[ $project_id -gt 17 ]]; then
      continue
fi
    # 下载导出文件
    echo "下载项目 $project_id 的导出文件..."  >> $LOG_FILE
    curl --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" -o "$EXPORT_DIR/project_$project_id.tar.gz" "$OLD_GITLAB_URL/api/v4/projects/$project_id/export/download"
    echo "项目 $project_id 导出完成，已下载文件到 $EXPORT_DIR/project_$project_id.tar.gz"
	sleep 5
    # 将项目导入到新 GitLab 实例
    echo "导入项目 ID: $project_id 到新 GitLab 实例..."  >> $LOG_FILE
    curl --silent --request POST --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" \
        --form "name=$project_name" --form "path=$project_path" --form "namespace=$namespace" --form "file=@$EXPORT_DIR/project_$project_id.tar.gz" \
        "$NEW_GITLAB_URL/api/v4/projects/import"
	sleep 5

    echo "项目 $project_id 导入完成。"  >> $LOG_FILE
done
echo "所有项目导出和导入操作已完成。"  >> $LOG_FILE


echo "开始用户数据迁移...."
# 获取所有活跃用户的 ID、名称、用户名和邮箱
user_info=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/users?page=1&per_page=100&active=true" | jq -c '.[] | {name: .name, username: .username, email: .email}')

# 遍历每个用户，检查并创建
echo "$user_info" | while IFS= read -r user; do
    name=$(echo "$user" | jq -r '.name')
    username=$(echo "$user" | jq -r '.username')
    email=$(echo "$user" | jq -r '.email')
    echo "$name $username $email"
    # 随机生成用户密码
    password=$(openssl rand -base64 12)

    # 检查用户是否已存在于新 GitLab 实例中
    existing_user_by_username=$(curl --silent --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" "$NEW_GITLAB_URL/api/v4/users?username=$username")
    existing_user_by_email=$(curl --silent --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" "$NEW_GITLAB_URL/api/v4/users?search=$email")

    if [[ "$existing_user_by_username" != "[]" ]]; then
        echo "用户 $username 已存在于新实例中，跳过创建。" >> $LOG_FILE
        continue
	fi
    if [[ "$existing_user_by_email" != "[]" ]]; then
        echo "邮箱 $email 已存在于新实例中，跳过创建。" >> $LOG_FILE
        continue
    fi

    # 创建新用户
    response=$(curl --silent --request POST --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" \
        --form "email=$email" --form "username=$username" --form "name=$name" --form "password=$password" \
        "$NEW_GITLAB_URL/api/v4/users")

    # 检查是否成功创建用户
    if echo "$response" | jq -e 'has("id")' > /dev/null; then
        echo "用户 $username 创建成功。 password: "$password >> $LOG_FILE
    else
        error_msg=$(echo "$response" | jq -r '.message // "未知错误"')
        echo "用户 $username 创建失败：$error_msg" >> $LOG_FILE
    fi
	sleep 1
done


urlencode() {
    local encoded=""
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) encoded+="$c" ;;
            *) encoded+=$(printf '%%%02X' "'$c") ;;
        esac
    done
    echo "$encoded"
}

echo "开始用户权限数据迁移...."

# 创建用户映射表 (username -> user_id 和 email -> user_id)
declare -A username_to_user_id
declare -A email_to_user_id

# 获取新 GitLab 实例的所有用户信息
all_users=$(curl --silent --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" "$NEW_GITLAB_URL/api/v4/users?page=1&per_page=100")
# 填充用户映射表
while read -r user; do
    user_id=$(echo "$user" | jq -r '.id')
    username=$(echo "$user" | jq -r '.username')
    email=$(echo "$user" | jq -r '.email')

    echo "用户数据：$username $email $user_id"

    # 建立 username 和 email 映射到 user_id 的关系
    username_to_user_id["$username"]="$user_id"
    email_to_user_id["$email"]="$user_id"
done < <(echo "$all_users" | jq -c '.[]')

# 获取所有项目的ID
projects=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/projects?page=1&per_page=100" | jq -c '.[] | {id: .id, name_with_namespace: .name_with_namespace}')
# 遍历每个项目，为用户在新 GitLab 中分配权限
echo "$projects" | while IFS= read -r project; do

  project_id=$(echo "$project" | jq -r '.id')
  name_with_namespace=$(echo "$project" | jq -r '.name_with_namespace')
  echo $project

    # 获取项目成员信息
    members=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/projects/$project_id/members/all")

    # 为每个成员重新分配权限
    echo "$members" | jq -c '.[]' | while read -r member; do
        username=$(echo "$member" | jq -r '.username')
        access_level=$(echo "$member" | jq -r '.access_level')

        # 优先使用 username 查找用户 ID
        user_id="${username_to_user_id[$username]}"

        # 如果username找不到用户ID，则尝试使用email查找
        if [[ -z "$user_id" ]]; then
            email=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/users?username=$username" | jq -r '.[0].email')
            user_id="${email_to_user_id[$email]}"
        fi

        # 如果找到user_id，则分配相应的权限
        if [[ -n "$user_id" ]]; then
          encoded_name_with_namespace=$(urlencode "$name_with_namespace")
          NEW_PRO_ID=$(curl --silent --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" "$NEW_GITLAB_URL/api/v4/projects?search_namespaces=true&search=$encoded_name_with_namespace" | jq -r '.[0].id')

            curl --silent --request POST --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" \
                --form "user_id=$user_id" --form "access_level=$access_level" \
                "$NEW_GITLAB_URL/api/v4/projects/$NEW_PRO_ID/members"
            echo "已为用户 $username (ID: $user_id) 分配项目 ID: $NEW_PRO_ID 的访问权限" >> $LOG_FILE
        else
            echo "用户 $username (ID: $user_id) 未在新实例中找到，跳过权限分配。" >> $LOG_FILE
        fi
		sleep 1
    done
done

# 获取所有群组的ID
groups=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/groups?page=1&per_page=100" | jq -c '.[] | {id: .id, name: .name}')
# 遍历每个群组，为用户在新 GitLab 中分配权限
echo "$groups" | while IFS= read -r group; do
    group_id=$(echo "$group" | jq -r '.id')
    name=$(echo "$group" | jq -r '.name')
    # 获取群组成员信息
    members=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/groups/$group_id/members")

    # 为每个成员重新分配权限
    echo "$members" | jq -c '.[]' | while read -r member; do
        username=$(echo "$member" | jq -r '.username')
        access_level=$(echo "$member" | jq -r '.access_level')

        # 优先使用 username 查找用户 ID
        user_id="${username_to_user_id[$username]}"

        # 如果username找不到用户ID，则尝试使用email查找
        if [[ -z "$user_id" ]]; then
            email=$(curl --silent --header "PRIVATE-TOKEN: $OLD_GITLAB_TOKEN" "$OLD_GITLAB_URL/api/v4/users?username=$username" | jq -r '.[0].email')
            user_id="${email_to_user_id[$email]}"
        fi

        # 如果找到user_id，则分配相应的权限
        if [[ -n "$user_id" ]]; then
            NEW_GROUP_ID=$(curl --silent --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" "$NEW_GITLAB_URL/api/v4/groups?search=$name" | jq -r '.[0].id')
            curl --silent --request POST --header "PRIVATE-TOKEN: $NEW_GITLAB_TOKEN" \
                --form "user_id=$user_id" --form "access_level=$access_level" \
                "$NEW_GITLAB_URL/api/v4/groups/$NEW_GROUP_ID/members"
            echo "已为用户 $username (ID: $user_id) 分配群组 ID: $NEW_GROUP_ID 的访问权限" >> $LOG_FILE
        else
            echo "用户 $username 未在新实例中找到，跳过权限分配。" >> $LOG_FILE
        fi
		sleep 1
    done
done
echo "权限同步完成。"  >> $LOG_FILE

echo "迁移Gitlab数据完成！"
