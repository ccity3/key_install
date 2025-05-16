# SSH Key Installer 脚本使用说明

这是一个方便的 SSH 公钥安装脚本，支持从 GitHub 账号、远程 URL 获取公钥，修改 SSH 端口，以及禁用密码登录。

---

## 脚本来源

- GitHub 仓库：[https://github.com/ccity3/key_install](https://github.com/ccity3/key_install)
- 脚本原始地址（用于下载）：  
  `https://raw.githubusercontent.com/ccity3/key_install/main/key.sh`

---

## 快速安装命令

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ccity3/key_install/main/key.sh) [选项]
```

---

## 使用说明

脚本支持以下选项（单个或组合使用）：

| 选项 | 说明                               | 参数               |
|-------|-----------------------------------|--------------------|
| `-w` | 覆盖模式，清空已有 `authorized_keys` | 无                 |
| `-g` | 从 GitHub 账号获取公钥             | GitHub 用户名       |
| `-r` | 从远程 URL 获取公钥                | 公钥文件的 URL      |
| `-p` | 修改 SSH 端口号                   | 新端口号（数字）    |
| `-d` | 禁用 SSH 密码登录                  | 无                 |

---

## 示例

- 从 GitHub 获取公钥并添加（追加）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ccity3/key_install/main/key.sh) -g username
```

- 从远程 URL 获取公钥并覆盖写入：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ccity3/key_install/main/key.sh) -w -r https://example.com/mykey.pub
```

- 修改 SSH 端口为 2222：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ccity3/key_install/main/key.sh) -p 2222
```

- 禁用 SSH 密码登录：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ccity3/key_install/main/key.sh) -d
```

---

## 注意事项

- 脚本执行需要有管理员权限（root）或能使用 `sudo`。
- 修改 SSH 配置后需要重启 sshd 服务，脚本会自动提示。
- 覆盖模式会清空已有的所有 `authorized_keys`，请谨慎使用。

---

如果有任何问题，请参考脚本中的注释或提交 issue。

---

祝使用顺利！
