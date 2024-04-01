# 快速使用

## 使用说明

### 构建

**需要注意的是**（参见 `dockerfile.dwx2` ）：

- 这个 docker 会自动创建普通用户，默认用户名为 normal，如果需要自己改用户名（改不改没啥影响）请修改你使用的 dockerfile 的 `ARG username` 那一行。
- 如果你的主机的用户 UID（`echo $UID`）不是 1000，请修改 `ARG uid` 那一行为你的 UID 数，否则显示不出来。
- 第 9 行设置 GitHub 镜像，如果有连接问题请自行挑选适合自己的镜像。
- 下面那个 wechat 下载链接上似乎有更新新版本（截止本次commit已达到 238），安装时把对应的 dockerfile 里版本（`Dockerfile.cwx2` 第 15 行或 `Dockerfile.dwx2` 第 4 行）改一下就好。

#### 全量构建方法

- 下载本仓库：`git clone https://gitee.com/KZ25T/docker-runs-wechat-and-wps.git`
- 自己八仙过海想办法下载 deb 包：[wechat](https://www.52pojie.cn/thread-1896902-1-1.html)，[WPS](https://archive.ubuntukylin.com/software/pool/partner/wps-office_11.1.0.11719_amd64.deb) 和 [weixin](http://archive.ubuntukylin.com/software/pool/partner/weixin_2.1.1_amd64.deb)，下载之后把这三个文件放在本仓库根目录内：

  ```bash
  # 放在和 README 同一位置
  # 如果版本不同，那么把 Dockerfile.dwx2 的 2-5 行改成自己的版本。
  wechat-beta_1.0.0.145_amd64.deb
  weixin_2.1.1_amd64.deb
  wps-office_11.1.0.11719_amd64.deb
  ```

- 执行 `docker build . -f Dockerfile.dwx2`，大概 2-5 分钟。

#### 只安装微信，不安装 WPS

和上面基本类似。不需要下载 WPS，另外删除 dockerfile 里的：

```text
## install input method and wps fonts
到
## wechat-beta
中间的那几行，以及

&& echo "ibus-daemon -d -x" >> /home/${username}/.bashrc \

这一行，以及ARG ttfurl、ARG wpsdeb、COPY wpsdeb 开头的那三行。
```

然后在注释 wechat beta 下的那一行 apt install 后面加上几个依赖：

```text
libxcomposite1 libxdamage1 libxfixes3 libcairo2 libatk-bridge2.0-0 libatk1.0-0 libpango-1.0-0 libgbm1 wget unzip
```

在下一行再加上：

```bash
&& mkdir -p /var/lib/dbus /usr/share/fonts/wps-office && echo "xxxxxx" > /var/lib/dbus/machine-id \
```

其中 `xxxxxx` 是 32 位 16 进制数，可以使用 `dbus-uuidgen` 或 `uuidgen` 生成，也可以自己随便写一个。

因为只需要运行微信，所以可以在 dockerfile 里设置容器启动命令：

```dockerfile
CMD [ "sh", "-c", "wechat" ]
```

### 运行

#### 全量运行

```bash
# 首次创建容器
docker image ls # 查看你构建的 IMAGE ID
docker run -it -u normal -e DISPLAY=$DISPLAY --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/document/docker:/home/normal/Documents 上一行查出来的ID
```

注意：第二条命令的第二个 `-v` 是创建主机和 docker 的交换目录，可以在这个目录上与主机共享文件。该目录在主机上为 `~/document/docker`，docker 容器内为 `/home/normal/Documents`，请根据情况自己修改。

```bash
# 后续启动容器
docker container ls -a # 查看上一步创建的 CONTAINER ID
docker start -ai 上一行查出来的ID
```

使用微信和 WPS：

- WPS 首次启动时，需新建一个文本文档，点击右上角第二行、从右数第四个 A 图标，语言改为中文。
- 第一个微信最开始可能要好几次才能成功。第二个微信比较稳定，但首次启动比较慢。

```bash
ibus engine pinyin # 启动拼音输入法
wechat & # 启动微信（后台，非阻塞）
wps & # 启动 WPS（后台，非阻塞）
wps 文件名 & # WPS 编辑某文件（后台，非阻塞）
```

#### 只安装微信的运行

首次创建容器时和上面类似，不需要 `run` 后带 `-it`；后续启动也不需要 `-ai`

这种情况我们可以做成一个图标：

```text
[Desktop Entry]
Exec=docker start 容器编号
Name=wechat
Name[zh_CN]=微信
Icon=weixin
Terminal=false
Type=Application
```

容器编号通过 `docker container ls -a` 的 container id 取得。`Icon` 字段可能需要考虑你自己电脑有没有对应的图标，没有图标的话可以去掉。

写到桌面上一个叫 `wechat.desktop` 文件里，双击即可执行（我只在我的 xfce 里测试过可用）
