;;; retro games website!!!

;; (ql:quickload "cl-who")
;; (ql:quickload "hunchentoot")
;; (ql:quickload "parenscript")

(defpackage :retro-games
  (:use :cl :cl-who :hunchentoot :parenscript)
  (:export :main))

(in-package :retro-games)

(defun main ()
  "Entry point when running from asdf"
  (print "Here we go...")
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 8080))
  (print "started")
  ;; (sb-thread:join-thread (find-if
  ;;                         (lambda (th)
  ;;                           (string (sb-thread:thread-name th) "hunchentoot"))
  ;;                         (sb-thread:list-all-threads))))
  (mapcar (sb-thread:list-all-threads) #'print))


;; Model for games


(defclass game ()
  ((name :reader name
         :initarg :name)
   (votes :accessor votes
          :initform 0)))

(defmethod vote-for-game (selected-game)
  "Cast a vote for SELECTED-GAME."
  (incf (votes selected-game)))

(defparameter the-greatest
  (make-instance 'game :name "San Francisco Rush"))


;; Backend storage and stuff


(defvar *games* '())


(defun game-from-name (game-name)
  "Look up a game given a name."
  (find game-name *games*
        :test #'string-equal
        :key #'name))

(defun game-stored? (game-name)
  (game-from-name game-name))

(defun games ()
  "Get a sorted list of all the games."
  (sort (copy-list *games*)
        #'>
        :key #'votes))

(defun add-game (name)
  "Add a game called NAME to our database."
  (unless (game-stored? name)
    (push (make-instance 'game :name name) *games*)))

;;
;; (add-game "Daytona USA")
;; (add-game "Hydro Thunder")
;; (games)
;; (mapcar 'add-game
;;         '("Galaga"
;;           "Pacman"
;;           "Time Crisis"
;;           "Joust"
;;           "Space Invaders"))
;;


;; Some Front End stuff now

;;
;; (with-html-output (*standard-output* nil :indent t)
;;   (:html
;;    (:head
;;     (:title "Test Page Please Ignore"))
;;    (:body
;;     (:p "This is actually pretty sweet.")
;;     (:p "Agreed. Big if true."))))
;;

(defmacro standard-page-template ((&key title) &body body)
  `(with-html-output-to-string (*standard-output*
                                nil
                                :prologue t
                                :indent t)
     (:html :xmlns "http://www.w3.org/1999/xhtml"
            :xml\:lang "en"
            :lang "en"
            (:head
             (:meta :http-equiv "Content-Type"
                    :content    "text/html;charset=utf-8")
             (:title ,title)
             (:link :type "text/css"
                    :rel "stylesheet"
                    :href "/retro.css"))
            (:body
             (:div :id "header" ; Retro games header
                   (:img :src "/logo.jpg"
                         :alt "logo here"
                         :class "logo")
                   (:span :class "strapline"
                          "Vote on your favourite Retro Game"))
             ,@body))))

;; (defun retro-games ()
;;   (standard-page-template
;;       (:title "Retro Games")
;;     (:h1 "Top 10 Retro Games")
;;     (:p "Under Construction...")))

;; (push (create-prefix-dispatcher "/retro-games.html"
;;                                 'retro-games)
;;       *dispatch-table*)

(defmacro define-url-fn ((name) &body body)
  `(progn
     (defun ,name ()
       ,@body)
     (push (create-prefix-dispatcher ,(format nil "/~(~a~).html" name)
                                     ',name)
           *dispatch-table*)))

(define-url-fn (retro-games)
  (standard-page-template
      (:title "Retro Games")
    (:h1 "Top 10 Retro Games OF ALL TIME")
    (:p "Don't see your favorite game listed?"
        (:a :href "new-game.html" "Add a new game"))
    (:h2 "Current standings:")
    (:div :id "chart"
          (:ol
           (dolist (game (games))
             (htm (:li
                   (:span :class "game-name"
                          (fmt "~A" (name game)))
                   (:span :class "game-votes"
                          (fmt "score: ~d" (votes game))
                          (:a :href (format nil "/vote-for.html?name=~a" (name game)) "vote")))))))))

(define-url-fn (vote-for)
  (let ((game (game-from-name (parameter "name"))))
    (if game
        (vote-for-game game))
    (redirect "/retro-games.html")))

(define-url-fn (game-added)
  (let ((name (parameter "name")))
    (unless (or (null name) (zerop (length name)))
      (add-game name))
    (redirect "/retro-games.html")))

(define-url-fn (new-game)
  (standard-page-template
      (:title "Add a new game")
    (:h1 "Add a new game to the list")
    (:form :action "/game-added.html" :method "post"
           :onsubmit
           (ps-inline
            (when (= name.value "")
              (alert "Please enter a name")
              (return false)))
           (:label "Game name:")
           (:input :type "text"
                   :name "name")
           (:button :type "submit" "Submit"))))
