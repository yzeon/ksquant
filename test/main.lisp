(in-package :ksquant)

(in-suite :ksquant-test)

(test simple-append.1
  (let ((a '((((0.0 :NOTES (60))
	       (0.2 :NOTES (60))
	       (0.4 :NOTES (60))
	       (0.6 :NOTES (60))
	       (0.8 :NOTES (60))
	       -1.0 4.0)
	      :INSTRUMENT :CONTRABASS)))
	(b '((((0.0 :NOTES (60))
	       (0.333 :NOTES (60))
	       (0.667 :NOTES (60))
	       -1.0 4.0)
	      :INSTRUMENT :CONTRABASS))))
    (finishes (simple-append t a b))
    (finishes (simple-append nil a b))
    (let* ((appended (simple-append nil a b))
	   (part (simple-change-type :part appended)))
      (multiple-value-bind (voices options)
	  (extract-options part)
	(is (eql :contrabass (getf options :instrument)))))))

(test simple-append.2
  (let ((a '((((0.0 :NOTES (60))
	       (0.2 :NOTES (60))
	       (0.4 :NOTES (60))
	       (0.6 :NOTES (60))
	       (0.8 :NOTES (60))
	       1.0)
	      :INSTRUMENT :CONTRABASS)))
	(b '((((0.0 :NOTES (60))
	       (0.333 :NOTES (60))
	       (0.667 :NOTES (60))
	       1.0)
	      :INSTRUMENT :CONTRABASS))))
    (finishes (simple-append t a b))
    (finishes (simple-append nil a b))))

(test simple-append.3
  (let ((a '((((0.0 :NOTES (60))
	       (0.2 :NOTES (60))
	       (0.4 :NOTES (60))
	       (0.6 :NOTES (60))
	       (0.8 :NOTES (60))
	       1.0))))
	(b '((((0.0 :NOTES (60))
	       (0.333 :NOTES (60))
	       (0.667 :NOTES (60))
	       1.0)))))
    (finishes (simple-append t a b))
    (finishes (simple-append nil a b))))

(test simple-shift.1
  (let ((a '((((0.0 :NOTES (60))
	       (0.2 :NOTES (60))
	       (0.4 :NOTES (60))
	       (0.6 :NOTES (60))
	       (0.8 :NOTES (60))
	       -1.0 4.0)
	      :INSTRUMENT :CONTRABASS))))
    (finishes (simple-shift a 0))
    (finishes (simple-shift a 1))
    (let* ((shifted (simple-shift a 1))
	   (part (simple-change-type :part shifted)))
      (multiple-value-bind (events options)
	  (extract-options part)
	(is (eql :contrabass (getf options :instrument)))))))

(test simple-length.1
  (let ((a '((((0.0 :NOTES (60))
	       (0.2 :NOTES (60))
	       (0.4 :NOTES (60))
	       (0.6 :NOTES (60))
	       (0.8 :NOTES (60))
	       -1.0 4.0)
	      :INSTRUMENT :CONTRABASS))))
    (finishes (simple-length a nil))
    (finishes (simple-length a t))))

(test simple-allowed-format.1
  ;; this should all be the same
  (let ((a '((((0.0 :NOTES (60))
	       -1.0
	       -1.5
	       (2.0 :NOTES (60))
	       4.0))))
	(b '((((0.0 :NOTES (60))
	       (-1.0)
	       -1.5
	       (2.0 :NOTES (60))
	       4.0))))
	(c '((((0.0 :NOTES (60))
	       (-1.0)
	       (-1.5)
	       (2.0 :NOTES (60))
	       4.0)))))
    (finishes (simple2score a))
    (finishes (simple2score b))
    (finishes (simple2score c))))


(test concat-rests.1
  (is (equal
       '(((1 ((1 :NOTES (60)) (1 :NOTES (60))))
	  (1 ((-1 :NOTES (60))))
	  (1 ((-1 :NOTES (60)) (1 :NOTES (60))))
	  (1 ((1 :NOTES (60)) (-1 :NOTES (60))))
	  :TIME-SIGNATURE
	  (4 4)
	  :METRONOME
	  (4 60)))
       (SIMPLE2VOICE '((0.0 :NOTES (60))
		       (0.5 :NOTES (60))
		       -1.0
		       -1.5
		       -2.0
		       (2.5 :NOTES (60))
		       (3.0 :NOTES (60))
		       -3.5
		       4.0)
		     :TIME-SIGNATURES
		     '(4 4)
		     :METRONOMES
		     '(4 60)
		     :SCALE
		     '1/4
		     :MAX-DIV
		     '8
		     :FORBIDDEN-DIVS
		     '(7)
		     :FORBIDDEN-PATTS
		     NIL
		     :MERGE-MARKER
		     :BARTOK-PIZZICATO))))

(test concat-rests.2
  (let ((a '((((0.0 :NOTES (60)) -4.0 -4.3 4.6 -4.8 (5.0 :NOTES (60)) (6.0 :NOTES (60)) 7.0)))))
    (finishes (simple2score a))))

(test concat-rests.3
  (let ((a '((0 :NOTES (60) :REST NIL)
	     (0.33333334 :NOTES NIL :REST T)
	     (0.61904765 :NOTES NIL :REST T)
	     (0.8857143 :NOTES NIL :REST T)
	     (1.2493507 :NOTES NIL :REST T)
	     (1.582684 :NOTES NIL :REST T)
	     (1.982684 :NOTES NIL :REST T)
	     (2.4826842 :NOTES (60) :REST NIL)
	     (3.0541127 :NOTES NIL :REST T)
	     4.387446)))
    (finishes (simple2score a))))

(test concat-rests.4
  (let ((a '((0 :NOTES (60) :REST NIL)
	     (0.3 :NOTES NIL :REST T)
	     (0.6 :NOTES NIL :REST T)
	     (0.8 :NOTES NIL :REST T)
	     (1.2 :NOTES NIL :REST T)
	     (1.6 :NOTES NIL :REST T)
	     (2.0 :NOTES NIL :REST T)
	     (2.5 :NOTES (60) :REST NIL)
	     (3.0 :NOTES NIL :REST T)
	     4.0)))
    (finishes (simple2score a))))

(defun random-float (from to)
  (let ((granity 100000)
	(diff (float (- to from))))
    (+ (float from)
       (* diff (float (/ (random granity) granity))))))

(test simple2score-no-rests-integers
  (for-all ((durs (5am:gen-list :length (5am:gen-integer :min 10 :max 20)
				:elements (5am:gen-integer :min 1 :max 5))))
    (finishes (simple2score (pitches-durs2simple '(60) durs)))))

(test simple2score-no-rests-floats
  (for-all ((durs (5am:gen-list :length (5am:gen-integer :min 10 :max 20)
				:elements #'(lambda () (random-float 1.0 6.0)))))
    (finishes (simple2score (pitches-durs2simple '(60) durs)))))

(test simple2score-no-rests-floats-small
  (for-all ((durs (5am:gen-list :length (5am:gen-integer :min 10 :max 20)
				:elements #'(lambda () (random-float 0.1 6.0)))))
    (finishes (simple2score (pitches-durs2simple '(60) durs)))))

(test simple2score-with-rests-floats-small
  (for-all ((durs (5am:gen-list :length (5am:gen-integer :min 10 :max 20)
				:elements #'(lambda () (let ((dur (random-float 0.1 6.0)))
							 (if (zerop (random 2))
							     dur
							     (* -1 dur)))))))
    (finishes (simple2score (pitches-durs2simple '(60) durs)))))

(test simple2score-no-rests-floats-small.gq
  (for-all ((durs (5am:gen-list :length (5am:gen-integer :min 10 :max 20)
				:elements #'(lambda () (random-float 0.1 6.0)))))
    (finishes (pw::gquantify durs))))

;; 5am:*debug-on-error*

