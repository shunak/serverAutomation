#!/bin/bash
##
## @(#)リモートサーバ上でタスクスクリプトを実行する
# スクリプトにエラーがあれば終了
# 未定義の変数があればエラーにする
# パイプのコマンドが失敗したらエラー
set -e
set -u
set -o pipefail

## コマンドを表示してから実行
run () {
echo -e "\033[34m [localhost] $ $1\033 [m" >&2
eval $1
}
## ssh の設定
ssh_user="USERNAME"
ssh_host="HOST"
ssh_port=22
ssh_key="PATHTOSSHKEY"
ssh_option=""
## ssh オプションを追加
[[ -z "$ssh_key"  ]] || ssh_option="-i $ssh_key $ssh_option"
[[ -z "$ssh_port" ]] || ssh_option="-p $ssh_port $ssh_option"
## rsync のオプション
#-a: まるごとコピー、 -v: 送信ファイル名を出力、 -z: 圧縮して通信、
#ー-delete: リストにないファイルは削除、 -e: 接続に使うssh コマンド
##
##
rsync_option="-avz -delete -e 'ssh $ssh_option'"
## リモートサーバにコピーするファイル
files="apt.bash"
## rsync でリモートサーバにファイルをコピー
remote=${ssh_user}@${ssh_host}
run "rsync $rsync_option $files $remote:serversetup/"
# 13: ubuntu@localhost
## ssh でリモートサーバに接続し、 スクリプトを実行
run "ssh -t $ssh_option $remote 'cd serversetup; bash apt.bash'"


