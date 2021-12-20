# AWS 클러스터 구축 용도 네트워크 구성 & Bastion Host용 EC2 설정

![Untitled](./Network/Untitled.png)

---

## 1. 네트워크 구성

### 	1) VPC 생성

* 이름 지정 및 IPv4 CIDR 지정
  * CIDR : 192.168.0.0/16![Untitled](./Network_IMG/Untitled%201.png)



### 2) Subnet 구성(public 2개, private 2개 생성)

#### 	(1) 서브넷 생성

* 1)에서 생성한 VPC를 지정 후, 2a용 public, private 각 1개씩 / 2b용 public, private 각 1개씩 총 4개 생성

  ![Untitled](./Network_IMG/Untitled%202.png)(1) subnet-public-2a : 192.168.0.0/24  /  (2) subnet-public-2c : 192.168.1.0/24

  (3) subnet-private-2a : 192.168.10.0/24  /  (4) subnet-private-2c : 192.168.20.0/24

  

### 3) 인터넷 게이트웨이 생성

* 이름 지정하여 생성 후, 우측 상단 작업 -> VPC에 연결 -> 1) 에서 생성한 VPC로 연결![Untitled](./Network_IMG/Untitled%203.png)



### 4) 라우팅 테이블 생성

​	1) 에서 생성한 vpc를 지정![Untitled](./Network_IMG/Untitled%204.png)



### 5) 라우팅 테이블에 게이트웨이, public subnet 연결

​	(1) 4.에서 생성한 게이트웨이 추가![Untitled](./Network_IMG/Untitled%205.png)

​	(2) 2.에서 생성한 public subnet 2개 연결(2a, 2b의 public Subnet![Untitled](./Network_IMG/Untitled%206.png)



### 6) NAT 게이트웨이 생성 - 총 2개 생성 (ap-northeast-2a / ap-northeast-2c 각기 1개씩)

* 2A용 게이트웨이는 Public-2A 서브넷 / 2C용 게이트웨이는 Public-2C를 각기 선택 후 생성한다.

* 탄력적 IP는 없을 경우 할당으로 생성하면 된다.

  ![Untitled](./Network_IMG/Untitled%207.png)

  

### 7) Private Subnet을 할당할 라우팅 테이블 생성 (Private A / Private C 각기 라우팅 테이블을 생성.)

​	(1) 1.의 VPC를 선택하여 새로운 라우팅 테이블 생성 후, 라우팅 편집으로 6. 에서 생성한 NAT 게이트웨이를 지정.

​			(2A용 라우팅테이블엔 2A용 NAT를 연결, 2C용 라우팅테이블엔 2C용 NAT를 연결)![Untitled](./Network_IMG/Untitled%208.png)

![Untitled](./Network_IMG/Untitled%209.png)



​	(2) 각 라우팅 테이블과 Private Subnet을 연결한다.

* Private-2A용 라우팅 테이블의 서브넷 연결![Untitled](./Network_IMG/Untitled%2010.png)

* Private-2C용 라우팅 테이블의 서브넷 연결![Untitled](./Network_IMG/Untitled%2011.png)



---



## 2. Bastion Host 역할용 인스턴스 생성 후, 설정 가이드

### 	1) apt 패키지 업데이트 및 시간대 설정

```bash
sudo -i
apt-get update

-------------------------
(Centos, Ubuntu 공통)
sudo timedatectl list-timezonex | grep -i Asia/Seoul

sudo timedatectl set-timezone Asia/Seoul
date

-------------------------
(ubuntu)
dpkg-reconfigure tzdata
-> Asia
-> Seoul 차례대로 선택

date
```

### 2) kubernetes 설치에 필요한 패키지 및 기타 패키지 설치 진행

```bash
sudo apt-get install -y apt-transport-https ca-certificates curl python3-pip
```

### 3) oh my zsh 설치 **(안해도 무방)**

```bash
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### 	(1) Powerlevel10k 테마

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

```bash
(~/.zshrc 파일에서 ZSH_THEME 내용 수정)
ZSH_THEME="powerlevel10k/powerlevel10k"
```

#### 	(2) autoupdate 플러그인

```bash
git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoupdate
```

```bash
~/.zshrc -> plugins=(~~ autoupdate)  autoupdate 내용 추가
```

#### 	(3) zsh-syntax-highlighting 플러그인

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

```bash
~/.zshrc -> plugins=(~~ zsh-syntax-highlighting)  zsh-syntax-highlighting 내용 추가
```

#### 	(4) 접속 유저의 기본 쉘 변경

```bash
sudo vim /etc/passwd

ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
-> ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/zsh
```

### 4) AWS CLI 설치

```bash
sudo apt install -y zip
```

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

```bash
unzip awscliv2.zip
```

```bash
sudo ./aws/install
```

### 5) Kubectl 설치

```bash
sudo curl -o /usr/local/bin/kubectl  \
   https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
```

```bash
sudo chmod +x /usr/local/bin/kubectl
```

```bash
kubectl version --client=true --short=true

# 출력되는 결과 값
Client Version: v1.21.2-13+d2965f0db10712
```

### 6) eksctl 설치

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
```

```bash
sudo mv -v /tmp/eksctl /usr/local/bin
```

```bash
eksctl version
```

```bash
mkdir -p ~/.zsh/completion/

mkdir -p ~/.bash/completion/
```

```bash
eksctl completion zsh > ~/.zsh/completion/_eksctl

eksctl completion bash > ~/.bash/completion/_eksctl
```

#### ~/.zshrc 파일 안에 다음 내용 저장

```bash
fpath=($fpath ~/.zsh/completion)
```

#### 아래명령 실행

```bash
autoload -U compinit
compinit
```

### 7) AWS IAM 인증 설치

```bash
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
```

```bash
chmod +x ./aws-iam-authenticator
```

```bash
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
```

```bash
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

echo 'export PATH=$PATH:$HOME/bin' >> ~/.zshrc
```

```bash
aws-iam-authenticator help
```

### 8) AWS 인증정보 등록

#### 	(1) 인증정보 생성 및 확인 메뉴

![Untitled](./Network/Untitled%2012.png)

#### 	(2) (1)에서 생성한 인증정보 등록

```bash
aws configure

AWS Access Key ID [****************GIPZ]: Access Key ID 입력
AWS Secret Access Key [****************DJFK]: Secret Access Key 입력
Default region name [ap-northeast-2]: ap-northeast-2
Default output format [json]: json
```

#### 	(3) aws sts get-caller-identity 로 입력 정보 확인

```bash
aws sts get-caller-identity

{
    "UserId": "~~~~~",
    "Account": "~~~~~",
    "Arn": "arn:aws:iam::~~~~~:~~~~~/~~~~~"
}
```

#### 	(4) ssh-keygen 으로 연결용 key 생성

```bash
ssh-keygen
```

#### 	(5) vimrc 설정(yaml 파일 문법용)

```bash
(~/.vimrc 파일에 다음 내용 입력 후 저장)
syntax on
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent
```