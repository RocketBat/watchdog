# README #

This README for watchdog write on perl.

### What is this repository for? ###

* Quick summary
* Version 1.7
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### TODO ###

* CORE features:
* * :white_check_mark: Process checking
* * :white_check_mark: Check that log is updating (file refreshing)
* * :white_check_mark: Check drops in log
* * :white_check_mark: Check zombie process
* Process features:
* * :white_check_mark: Multithreading
* Notifications:
* * :white_check_mark: Sending email
* * :no_entry: history of previous bypass state
* Common:
* * :no_entry: Check that traffic is come
* Statistics:
* * :no_entry: Own statistics (ex. how many times bypass change state)

---

## Имеюшиеся зависимости в проекте ##

1. File::chdir

2. MCE

3. Config::Tiny

---

## Sendmail ##

Для того чтобы посылалась почта нужен модуль sendmail.

Настраивается примерно так:

1. Ставим sendmail

2. Делаем чтобы почта посылалась с gmail'а:

* * apt-get install ssmtp

* * nano /etc/ssmtp/ssmtp.conf

* * * AuthUser=pochta@gmail.com
* * * AuthPass=Your-Gmail-Password
* * * FromLineOverride=YES
* * * mailhub=smtp.gmail.com:587
* * * UseSTARTTLS=YES

З.ы.: желательно выключить при этом sendmail, но не обязательно