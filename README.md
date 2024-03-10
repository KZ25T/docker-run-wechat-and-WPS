# docker 运行微信和 WPS

英文版没有，也没必要有

## 起因

国内 linux 用户，很多都对微信比较头疼。这软件很不干净，目录乱的很，运行条件也奇奇怪怪，速度也慢。这里我使用优麒麟封装的微信，那个是用网页版微信封装的，**不是 wine**，勉强算是能运行。

WPS有 linux 版，不过 linux 版看起来也很有些问题，比如不知道会添加什么启动项，导致每次登录都会产生一个目录 `~/模板` 而不是遵循 `XDG_TEMPLATES_DIR`（参见`~/.config/user-dirs.dirs`），跟开发人员说了他们觉得这是 feature 而不是 bug，那我也觉得你这玩意是流氓软件而不是规范软件。另外从终端启动根本不打印错误信息，运行错误都不知道怎么错的，我好不容易给调好了，所以做成 docker 用。

## 使用说明

### 构建

下载本仓库，执行 `docker build .`，大概 5-10 分钟就好了。

需要注意的是（参见 Dockefile）：

- wps 官网的 cdn 比较奇怪，所以我这里还使用优麒麟的软件源，以免出什么问题。
- 这个 docker 会自动创建普通用户，如果需要自己改用户名请修改第 7 行。如果你的主机的用户 UID（`echo $UID`）不是 1000，请修改第 8 行为你的 UID 数，否则显示不出来。
- 第 9 行设置 GitHub 镜像，如果有连接问题请自行挑选适合自己的镜像。

### 运行

```bash
# 首次创建容器
docker image ls # 查看你构建的 IMAGE ID
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/document/docker:/home/host 上一行查出来的ID
```

注意：第二条命令的第二个 `-v` 是创建主机和 docker 的交换目录，在主机上为 `~/document/docker`，docker 容器内为 `/home/host`，有需要的自己修改。

```bash
# 后续启动容器
docker container ls -a # 查看上一步创建的 CONTAINER ID
docker start -ai 上一行查出来的ID
```

使用微信和 WPS：

- WPS 首次启动时，需新建一个文本文档，点击右上角第二行、从右数第四个 A 图标，语言改为中文。

```bash
su normal - # 进入普通用户
ibus engine pinyin # 启动拼音输入法
wx # 启动微信（后台，非阻塞）
wps & # 启动 WPS（后台，非阻塞）
wps 文件名 & # WPS 编辑某文件（后台，非阻塞）
```

## 结语

希望某些国产软件正经开发、正常发展，开发规范的 linux 发行版，不要搞窝里斗。
