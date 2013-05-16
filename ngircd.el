;;; ngircd.el --- start ngircd servers from emacs

;; Copyright (C) 2013  Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Keywords: processes

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Start ngircd from Emacs.

;;; Code:

(require 's)

(defconst ngircd/conf-template "# config
[Global]
 Name = ${server-name}
 Info = \"${info}\"
 AdminInfo1 = teamchat admin
 AdminInfo2 = Sussex
 AdminEMail = support@teamchat.net
 Ports = ${tcp-port}
 Listen = 127.0.0.1
 MotdFile = ${motd-file-name}
 PidFile = ${pid-file-name}
[Limits]
 PingTimeout = 120
 PongTimeout = 20
 ConnectRetry = 60
 MaxConnections = 210
 MaxConnectionsIP = 40
 MaxJoins = 10
 MaxNickLength = 20
[Options]
 OperCanUseMode = yes
")

(defun ngircd/make-motd ()
  "Make a MOTD file.

Fill it in and return the file name."
  (let ((motd-file-name (make-temp-file "ngircd" nil ".motd")))
    (with-temp-file motd-file-name
      (insert "welcome to the ircd\n"))
    motd-file-name))

(defvar ngircd/ports-used (make-hash-table :test 'equal)
  "Hashtable of used TCP ports, key: tcp port, value: process.")

(defvar ngircd/server-names (make-hash-table :test 'equal)
  "Hashtable of server names, key: server-name, value: process.")

(defun* ngircd-start-process (&key (port 9001))
  (interactive)
  (let* ((server-name "myserver.localhost")
         (info "the myserver for me")
         (tcp-port 9001)
         (motd-file-name (ngircd/make-motd))
         (pid-file-name (make-temp-file "ngircd" nil ".pid"))
         (conf-file-name (make-temp-file "ngircd" nil ".conf")))
    (with-temp-file conf-file-name
      (insert (s-lex-format ngircd/conf-template)))
    ;; Create the process
    (let ((proc 
           (start-process
            "ngircd" "*ngircd*"
            "/usr/sbin/ngircd" "-n" "-f" conf-file-name)))
      (puthash server-name proc ngircd/server-names)
      (puthash tcp-port proc ngircd/ports-used))))


(provide 'ngircd)

;;; ngircd.el ends here
