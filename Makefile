.PHONY: slow bench clean check_slow

slow:
	sudo mysqldumpslow -s t /var/lib/mysql/slow.log

bench:
	cd bench && ./bench -target-addr 127.0.0.1:443

clean:
	sudo rm /var/lib/mysql/slow.log
	sudo touch /var/lib/mysql/slow.log

check_slow:
	mysql -u root -proot isuports  -e 'show variables like "slow_query%"'
	mysql -u root -proot isuports  -e 'show variables like "long_query_time"'
	mysql -u root -proot isuports  -e 'show variables like "log_queries_not_using_indexes"'


restart:
	sudo service mysql restart

cardinaliry:
	# カーディナリティ調べるSQL
	@echo "30秒くらいかかるかも、気長に待ってね"
	@# mysql -u root -proot isuports -e 'select player_id,tenant_id,COUNT(*) FROM visit_history GROUP BY player_id,tenant_id' # キー種類数
	mysql -u root -proot isuports -e 'select COUNT(DISTINCT player_id,tenant_id) AS "キー種類数" FROM visit_history'
	mysql -u root -proot isuports -e 'SELECT COUNT(*) AS "全件件数" from visit_history'
	# カーディナリティ = キー種類数 / 全件件数
	# 5%以下がINDEX貼る目安。30%以上はINDEXを貼ると逆に悪化とされている（諸説あり）
	@# 参考（上にあるけど再掲）：https://old.insight-tec.com/blog/mailmagazine-ora3-vol112/

# /etc/mysql/mysql.conf.d/mysqld.cnf

gitssh:
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_git
	echo "host github github.com\n  HostName github.com\n  IdentityFile ~/.ssh/id_rsa_git\n  User git" >> ~/.ssh/config
	@echo "https://github.com/settings/keys で New SSH keyを押下し、以下のpublic keyをペーストしてください"
	cat ~/.ssh/id_rsa_git.pub

gitalias:
	git config --global alias.st status
	git config --global alias.ci commit
	git config --global alias.br branch
	git config --global alias.co checkout

gitset_user_%:
	@git config --global user.name $*
	@echo "Update! : user.name = $*"

gitset_email_%:
	@git config --global user.email $*
	@echo "Update! : user.email = $*"

flours: gitset_user_flours gitset_email_tada@unirobot.com

retch: gitset_user_reatoretch gitset_email_reatoretch@gmail.com

ln:
	set -eu
	sudo mv $(FILE) $(shell pwd)
	sudo ln -s $(shell pwd)/$(notdir $(FILE)) $(FILE)

unlink:
	sudo unlink $(FILE)
