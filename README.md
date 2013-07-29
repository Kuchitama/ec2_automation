ec2_automation
==============

Chefを利用したAMIの作成／更新を自動化するフレームワークです。

# 基本動作

## crate_ami

chefを利用したAMIの自動作成を行います。

1. 指定されたamiからEC2インスタンスを立ち上げ、
2. knife-soloを使いchef-repo内のchef-recipeを実行し、
3. 更新されたEC2インスタンスから新たにAMIを作成します

## web_api

webサーバを起動し、POSTリクエストを受け取ったタイミングで、create_amiを実行します。

GitHubやBitBucketなどのpushをフックして呼び出す事が出来ます。

# Requirements

* ruby-1.9.3
* rubygems
* Bundler
* Chef
* knife-solo
* Berkshelf


# 利用方法

## 1.インストール

gitからクローン

```sh
]$ git clone https://github.com/Kuchitama/ec2_automation.git
```

依存gemをbundlerで取得

```sh
]$ cd ec2_automation.git
]$ bundle install
```

## 2.config編集

config.yml.templateを元にconfig.ymlを編集します。

```sh
]$ mv config.yml.template config.yml
]$ vi config.yml
```

## 3.chef-repository

chef-repoを編集します。knife-solo+Berkshelfを利用出来ます。

```sh
]$ cd chef-repo
]$ vi Berksfile


]$ berks install
]$ cd ..
```

## 4.run_list編集

chefのjson設定は、template.jsonに記述します。

run_listや、利用するcookbookのattributeなどを書いてください。

```sh
]$ vi template.json

```

## 5.実行

create_ami.rbを実行します。

```sh
]$ ruby create_ami.rb
```

