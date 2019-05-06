# 在目标服务器执行相关命令
# 知道目标服务器密码

# coding=utf-8
# 该文已以装rsync为示例

__author__ = 'YongQc'
# 目标服务器文件 'ip:帐号:密码' 格式配置。多个服务器以多行配置
target_server_file = '/data/server.txt'

def build_cmd(account, ip):
    sync_cmd = "ssh %s@%s 'yum install rsync -y'" % (account, ip)
    return sync_cmd


def run_cmd(cmd, password):
    import pexpect
    print cmd
    child = pexpect.spawn(cmd)
    child.timeout = 3000
    try:
        while True:
            i = child.expect(['password:', 'continue connecting (yes/no)?'])
            if i == 0:
                child.sendline(password)
                break
            elif i == 1:
                child.sendline('yes')
            else:
                break
    except pexpect.EOF:
        print
    else:
        child.expect(pexpect.EOF)
        child.close()


def do_install():
    global target_server_file
    _file = open(target_server_file)
    for line in _file:
        _line_str = line.strip('\n').split(':')
        cmd = build_cmd(_line_str[1], _line_str[0])
        run_cmd(cmd, _line_str[2])
        print('[%s] 安装完毕')

    _file.close()
    print("全部安装完毕！")


if __name__ == '__main__':
    do_install()
