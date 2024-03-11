# docker 运行微信和 WPS

英文版没有，也没必要有

No English version, because it is designed for linux users in China.

## 起因

国内 linux 用户，很多都对微信比较头疼。这软件很不干净，目录乱的很，运行条件也奇奇怪怪，速度也慢。

这里我使用了两个不同的微信构建了两个不同的 dockerfile：

- （不推荐）第一个使用优麒麟封装的微信，那个是用网页版微信封装的，**不是 wine**，勉强算是能运行，但不稳定。
- （推荐）第二个使用的最新泄露的 linux 原生支持的微信，不过是测试版，存在一些问题，但总归还算稳定。

在我的 docker 里，两个微信**都无法输入中文**，但支持剪切板直通（包括图片），所以可以**从外部输入中文之后复制粘贴到微信里**。这俩微信都不支持 ibus，而 fcitx 的安装体积大且麻烦，所以我只使用了 ibus 支持 wps 的输入。（我觉得 wps 对输入的要求更高，微信输入频率较低，闲聊的都用手机了，所以优先满足 wps）

WPS有 linux 版，不过 linux 版看起来也很有些问题，比如不知道会添加什么启动项，导致每次登录都会产生一个目录 `~/模板` 而不是遵循 `XDG_TEMPLATES_DIR`（参见`~/.config/user-dirs.dirs`），跟开发人员说了他们觉得这是 feature 而不是 bug，那我也觉得你这玩意是流氓软件而不是规范软件。另外从终端启动根本不打印错误信息，运行错误都不知道怎么错的，我好不容易给调好了，所以做成 docker 用。

## 使用说明

### 构建

记得**先看下边的注意**

使用第一个微信：

- 下载本仓库：`git clone https://gitee.com/KZ25T/docker-runs-wechat-and-wps.git`
- 执行 `docker build .`，默认使用的 dockerfile 是 `./Dockerfile` 大概 5-10 分钟就好了。

使用第二个微信：

- 下载本仓库。
- 下载新版微信安装包：[下载链接](https://www.52pojie.cn/thread-1896902-1-1.html)，把文件 `wechat-beta_1.0.0.145_amd64.deb` 放在本仓库根目录内，也就是和 `README.md` 处于同一目录。该下载链接需要注册123网盘，如果你认识本仓库的作者可以直接索取。
- 执行 `docker build . -f Dockerfile.wx2`，大概 5-10 分钟就好了（推荐使用 `Dockerfile.cwx3`，构建结果更小）。

**需要注意的是**（参见 build 使用的 dockerfile）：

- wps 官网的 cdn 比较奇怪，所以我这里还使用优麒麟的软件源，以免出什么问题。
- 这个 docker 会自动创建普通用户，默认用户名为 normal，如果需要自己改用户名（改不改没啥影响）请修改你使用的 dockerfile 的第 7 或 8 行（ARG username那一行）。如果你的主机的用户 UID（`echo $UID`）不是 1000，请修改第 8 或 9 行（ARG uid那一行）为你的 UID 数，否则显示不出来。
- 第 9 行设置 GitHub 镜像，如果有连接问题请自行挑选适合自己的镜像。

我的构建结果，两种方案的大小分别为 3.14 GB 和 3.32 GB，采取 Dockerfile.cwx2 构建结果为 2.73 GB

### 运行

```bash
# 首次创建容器
docker image ls # 查看你构建的 IMAGE ID
docker run -it -u normal -e DISPLAY=$DISPLAY --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/document/docker:/home/normal/Documents 上一行查出来的ID
```

注意：第二条命令的第二个 `-v` 是创建主机和 docker 的交换目录，可以在这个目录上传输文件。该目录在主机上为 `~/document/docker`，docker 容器内为 `/home/normal/Documents`，请根据情况自己修改。

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
wx # 启动微信（第一个版本，后台，非阻塞）
wechat & # 启动微信（第二个版本，后台，非阻塞）
wps & # 启动 WPS（后台，非阻塞）
wps 文件名 & # WPS 编辑某文件（后台，非阻塞）
```

## 结语

希望某些国产软件正经开发、正常发展，开发规范的 linux 发行版，不要搞窝里斗。
