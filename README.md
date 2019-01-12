# createk8s
create kubernetes 
参考  https://www.cnblogs.com/ericnie/p/7749588.html

1.关掉selinux

	vi /etc/selinux/config
	disabled
2.关掉firewalld,iptables
	systemctl disable firewalld
	systemctl stop firewalld
	systemctl disable iptables
	systemctl stop iptables
 

3.先设置主机名
	hostnamectl set-hostname k8s-1

4.修改/etc/hosts文件
	cat /etc/hosts
	127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
	::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
	192.168.0.105    k8s-1
	192.168.0.106    k8s-2
	192.168.0.107    k8s-3

5.修改网络配置成静态ip,然后
	service network restart

6. 配置kubelet使用国内pause镜像
   配置kubelet的cgroups
   获取docker的cgroups

	DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)

	echo $DOCKER_CGROUPS

	cat >/etc/sysconfig/kubelet<<EOF
	KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
	EOF


docker pull registry.cn-hangzhou.aliyuncs.com/kuberimages/kube-apiserver:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/kuberimages/kube-controller-manager:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/rsq_kubeadm/kube-scheduler:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/kuberimages/kube-proxy:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd-amd64:3.2.24
docker pull registry.cn-hangzhou.aliyuncs.com/kuberimages/coredns:1.2.6

docker tag registry.cn-hangzhou.aliyuncs.com/kuberimages/kube-apiserver:v1.13.0 k8s.gcr.io/kube-apiserver:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/kuberimages/kube-controller-manager:v1.13.0 k8s.gcr.io/kube-controller-manager:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/rsq_kubeadm/kube-scheduler:v1.13.0 k8s.gcr.io/kube-scheduler:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/kuberimages/kube-proxy:v1.13.0 k8s.gcr.io/kube-proxy:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd-amd64:3.2.24 k8s.gcr.io/etcd:3.2.24
docker tag registry.cn-hangzhou.aliyuncs.com/kuberimages/coredns:1.2.6 k8s.gcr.io/coredns:1.2.6



7.编辑生成kubernetes的yum源
cat /etc/yum.repos.d/kubernetes.repo
	[kubernetes]
	name=Kubernetes
	baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
	enabled=1
	gpgcheck=0

8.安装kubelet,kubectl,kubenetes-cni,kubeadm，缺省安装的是1.7.5版本
	yum install kubectl kubelet kubernetes-cni kubeadm 
	sysctl net.bridge.bridge-nf-call-iptables=1


9.init初始化master
	kubeadm init --kubernetes-version=v1.13.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.38.128 --apiserver-cert-extra-sans=192.168.38.128,192.168.38.130,192.168.38.131,127.0.0.1,host128,host130,host131,192.168.0.1 --ignore-preflight-errors=all
