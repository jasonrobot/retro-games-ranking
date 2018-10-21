;;; retro-games-system

(in-package :cl-user)
(defpackage :retro-games-system
  (:use :asdf))
(in-package :retro-games-system)

(defsystem "retro-games"
  :version "0.1.0"
  :author "Jason Howell"
  :license "LLGPL"
  :description "Practice little lisp web thing."
  ;;end docs
  :depends-on ("cl-who" "hunchentoot" "parenscript")
  :components ((:file "retro-games"))
  ;;binary build
  :build-operation program-op
  :build-pathname "retro-games" ;; shell name
  :entry-point "retro-games:main")
  ;;test build
  ;; :perform (test-op (o c)
  ;;                   (uiop:symbol-call :fiveam '#:run!
  ;;                                     (uiop:find-symbol* '#:retro-games/rename-test
  ;;                                                        :retro-games-test))))
