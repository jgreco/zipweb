#!/usr/bin/env guile -x .guile.sls -x .sls
!#
(define-module (zipweb main)
               #:use-module (compression zip)
               #:use-module (ice-9 regex)
               #:use-module (ice-9 hash-table)
               #:use-module (srfi srfi-1)
               #:use-module (web server)
               #:use-module (web request)
               #:use-module (web uri))

; open zip file
; TODO - getopt-long, --help, --version, etc
(define zip-file (second (program-arguments)))
(define zip-port (open-file zip-file "rb"))

; Content-Type
(define mime-map (alist->hash-table
                   '(("jpg" . (image/jpg (charset . "ISO-8859-1")))
                     ("png" . (image/png (charset . "ISO-8859-1")))
                     ("gif" . (image/gif (charset . "ISO-8859-1")))
                     ("zip" . (application/zip (charset . "ISO-8859-1")))
                     ("html" . (text/html))
                     ("htm" . (text/html))
                     ("css" . (text/css))
                     ("js" . (application/javascript)))))

(define (filename->content-type filename)
  (let* ((mtch (string-match "\\.([a-zA-Z0-9]+)$" filename))
         (ext (if mtch (match:substring mtch 1) #f)))
         (hash-ref mime-map ext '(application/octet-stream (charset . "ISO-8859-1")))))

; map filenames to zip CD entries
(define zip-cd   (get-central-directory zip-port))
(define (natural? x) (and (number? x) (not (zero? x))))
(define file-hash
  (alist->hash-table
    (map (λ (cd) (cons (string-append "/" (central-directory-filename cd)) cd))
         (filter (λ (cd) (natural? (central-directory-compressed-size cd)))
                 zip-cd))))

; unzip a filename to a port
(define (write-out-file filename out)
  (let ((file-cd (hash-ref file-hash filename)))
    (when file-cd
      (extract-to-port zip-port 
                       (central-directory->file-record zip-port file-cd)
                       file-cd
                       out))))

; handle requests
; TODO 404
;      / -> index.html
;      list directory if no index.html
(define (dezip-handler request request-body)
  (let ((path (uri-decode (uri-path (request-uri request)))))
    (values `((content-type . ,(filename->content-type path)))
            (λ (out) (write-out-file path out)))))

(run-server dezip-handler)
