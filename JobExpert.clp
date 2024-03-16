;;;======================================================
;;;     Rani Nirmala Prakoso (22/493982/TK/54153)
;;;	The Job Expert system.
;;;     This helps you select a job based on who you are
;;;======================================================

;; DEFFUNCTIONS
;; This function iteratively asks the questions

(deffunction next-questionnaire (?questionnaire ?allowed-values)
   (printout t ?questionnaire crlf)
   (printout t "reply: ")
   (bind ?reply (read))
   (printout t crlf)
   (if (lexemep ?reply) then (bind ?reply (lowcase ?reply)))
   (while (not (member ?reply ?allowed-values)) do
      (printout t ?questionnaire crlf)
      (printout t "reply: ")
      (bind ?reply (read))
      (printout t crlf)
      (if (lexemep ?reply) then (bind ?reply (lowcase ?reply))))
   ?reply)

;;  INIT 
;; This rule prints the initial information about the program

(defrule start
  (declare (salience 10000))
  =>
  (set-fact-duplication TRUE)
  (printout t "" crlf)
  (printout t "The JOBEX career quiz will help you decide the sort of jobs that will suit you best:" crlf)
  (printout t "" crlf)
  (printout t "Accepted replies:" crlf)
  (printout t "-------------------------------------" crlf)
  (printout t " Value           Meaning " crlf)
  (printout t "-------------------------------------" crlf)
  (printout t " -1              Definitely Not "	crlf)
  (printout t " -0.8            Almost certainly not "	crlf)
  (printout t " -0.6            Probably not "	crlf)
  (printout t " -0.4            Maybe not "	crlf)
  (printout t "  0              Unknown "	crlf)
  (printout t "  0.4            Maybe "	crlf)
  (printout t "  0.6            Probably "	crlf)
  (printout t "  0.8            Almost certainly "	crlf)
  (printout t "  1              Definitely "	crlf)
  (printout t "-------------------------------------" crlf)
  (printout t "" crlf))

;; Form of the facts

(deftemplate a-fact
   (slot name)
   (slot cf (default 0)))

;;  COMBINE CERTAINTIES 
;; Certainty factor combination rules

(defrule combine-certainties-1 (declare (salience 100)(auto-focus TRUE))
  ?fact1 <- (a-fact (name ?id) (cf ?cf1))
  ?fact2 <- (a-fact (name ?id) (cf ?cf2))
  (test (neq ?fact1 ?fact2))
  (test (> ?cf1 0))
  (test (> ?cf2 0))
  =>
  (retract ?fact1)
  (modify ?fact2 (cf (+ ?cf1 (* ?cf2 (- 1 ?cf1))))))

(defrule combine-certainties-2 (declare (salience 100)(auto-focus TRUE))
  ?fact1 <- (a-fact (name ?id) (cf ?cf1))
  ?fact2 <- (a-fact (name ?id) (cf ?cf2))
  (test (neq ?fact1 ?fact2))
  (test (< ?cf1 0))
  (test (< ?cf2 0))
  =>
  (retract ?fact1)
  (modify ?fact2 (cf (+ ?cf1 (* ?cf2 (+ 1 ?cf1))))))

(defrule combine-certainties-3 (declare (salience 100)(auto-focus TRUE))
  ?fact1 <- (a-fact (name ?id) (cf ?cf1))
  ?fact2 <- (a-fact (name ?id) (cf ?cf2))
  (test (neq ?fact1 ?fact2))
  (test (> ?cf1 0))
  (test (< ?cf2 0))
  =>
  (retract ?fact1)
  (modify ?fact2 (cf (/ (+ ?cf1 ?cf2) (- 1 (min (abs ?cf1) (abs ?cf2)))))))

;; COMBINE CERTAINTIES 
;; Certainty factor combination rules based on Durkin (1994)

;; Rule to combine Certainty Factors for supporting evidences
(defrule combine-certainties-supporting
  ?fact1 <- (a-fact (name ?id) (cf ?cf1))
  ?fact2 <- (a-fact (name ?id) (cf ?cf2))
  (test (neq ?fact1 ?fact2))
  (test (> ?cf1 0))
  (test (> ?cf2 0))
  =>
  (retract ?fact1)
  (modify ?fact2 (cf (+ ?cf1 (* ?cf2 (- 1 ?cf1))))))

;; Rule to combine Certainty Factors for conflicting evidences
(defrule combine-certainties-conflicting
  ?fact1 <- (a-fact (name ?id) (cf ?cf1))
  ?fact2 <- (a-fact (name ?id) (cf ?cf2))
  (test (neq ?fact1 ?fact2))
  (test (< ?cf1 0))
  (test (< ?cf2 0))
  =>
  (retract ?fact1)
  (modify ?fact2 (cf (+ ?cf1 (* ?cf2 (+ 1 ?cf1))))))

;; Rule to combine Certainty Factors for independent evidences
(defrule combine-certainties-independent
  ?fact1 <- (a-fact (name ?id) (cf ?cf1))
  ?fact2 <- (a-fact (name ?id) (cf ?cf2))
  (test (neq ?fact1 ?fact2))
  (test (> ?cf1 0))
  (test (< ?cf2 0))
  =>
  (retract ?fact1)
  (modify ?fact2 (cf (/ (+ ?cf1 ?cf2) (- 1 (min (abs ?cf1) (abs ?cf2)))))))

;;  QUESTIONNAIRE 
;; Form of the questions

(deftemplate questionnaire
   (slot a-fact (default ?NONE))
   (slot the-questionnaire (default ?NONE))
   (slot already-asked (default FALSE)))

;; Rule for asking a question

(defrule ask-a-questionnaire
   ?f <- (questionnaire (already-asked FALSE)
                        (the-questionnaire ?the-questionnaire)
                        (a-fact ?the-fact))
   =>
   (modify ?f (already-asked TRUE))
   (bind ?accepted (create$ -1 -0.8 -0.6 -0.4 0 0.4 0.6 0.8 1))
   (assert (a-fact (name ?the-fact) (cf (next-questionnaire ?the-questionnaire ?accepted)))))

;; List of questions

(deffacts questionnaire-facts
  (questionnaire (a-fact q1)
                 (the-questionnaire "I spend most of my spare time actively socialising with friends, attending parties, shopping, etc. "))
  (questionnaire (a-fact q2)
                 (the-questionnaire "I enjoy watching and playing team sports. "))
  (questionnaire (a-fact q3)
                 (the-questionnaire "Being around a group of people gives me energy. "))
  (questionnaire (a-fact q4)
                 (the-questionnaire "I would rather cook than go eat out in a restaurant. "))
  (questionnaire (a-fact good-with-computers)
                 (the-questionnaire "I am very good with computers. "))
  (questionnaire (a-fact q6)
                 (the-questionnaire "I improvise based on my past experience rather than looking for theoretical understanding. "))
  (questionnaire (a-fact q7)
                 (the-questionnaire "I am comfortable working with ambiguous or incomplete information/data and guessing its meaning."))
  (questionnaire (a-fact q8)
                 (the-questionnaire "I like to work around targets, deadlines and routines for managing my life. ")))

;;  THE RULES 
;; Based on the answers to the questions these rules infer facts

(defrule rule1
  (or
    (a-fact (name q1) (cf ?cf1))
    (a-fact (name likes-sports) (cf ?cf1)))
  =>
  (if (>= ?cf1 0.4) 
       then 
      (assert (a-fact (name is-social) (cf (* 0.8 ?cf1))))
      (assert (a-fact (name is-active) (cf (* 0.6 ?cf1))))
      (assert (a-fact (name likes-outdoor-activities) (cf (* 0.8 ?cf1))))
      (assert (a-fact (name likes-indoor-activities) (cf (* 0.8 ?cf1))))
      (assert (a-fact (name likes-spending) (cf (* 0.8 ?cf1))))
       else (if (<= ?cf1 -0.4)
                then (assert (a-fact (name is-introvert) (cf (* 0.6 ?cf1))))
                     (assert (a-fact (name likes-indoor-activities) (cf (* 0.9 ?cf1)))))))

(defrule rule2
  (and 
      (a-fact (name q2) (cf ?cf1))
      (a-fact (name q3) (cf ?cf2)))
  =>
  (if (and (>= ?cf1 0.4) (>= ?cf2 0.4))
       then 
      (assert (a-fact (name likes-sports) (cf (* 0.8 (min ?cf1 ?cf2)))))
      (assert (a-fact (name is-social) (cf (* 0.6 (min ?cf1 ?cf2)))))
      (assert (a-fact (name is-leader) (cf (* 0.7 (min ?cf1 ?cf2)))))
      (assert (a-fact (name likes-teaching) (cf (* 0.7 (min ?cf1 ?cf2)))))
      else (if (and (<= ?cf1 -0.4) (<= ?cf2 -0.4))
            then (assert (a-fact (name is-introvert) (cf (* 0.6 (min ?cf1 ?cf2)))))
                 (assert (a-fact (name is-follower) (cf (* 0.7 (min ?cf1 ?cf2))))))))

(defrule rule3
  (or 
      (a-fact (name q4) (cf ?cf1))
      (a-fact (name is-social) (cf ?cf1)))
  =>
  (if (>= ?cf1 0.4) 
       then 
      (assert (a-fact (name is-introvert) (cf (* 0.9 ?cf1))))
      (assert (a-fact (name is-follower) (cf (* 0.7 ?cf1))))
      (assert (a-fact (name is-leader) (cf (* 0.7 ?cf1))))
      (assert (a-fact (name likes-teaching) (cf (* -0.7 ?cf1))))
      else (if (<= ?cf1 -0.4)
            then (assert (a-fact (name is-active) (cf (* 0.6 ?cf1)))))))

(defrule rule4
  (a-fact (name good-with-computers) (cf ?cf1))
  =>
  (if (>= ?cf1 0.4)
       then 
      (assert (a-fact (name likes-indoor-activities) (cf (* 0.9 ?cf1))))
      (assert (a-fact (name likes-outdoor-activities) (cf (* -0.7 ?cf1))))
      (assert (a-fact (name is-follower) (cf (* -0.7 ?cf1))))
      else (if (<= ?cf1 -0.4)
          then (assert (a-fact (name is-active) (cf (* 0.6 ?cf1)))))))


(defrule rule5
  (and
    (a-fact (name q6) (cf ?cf1))
    (a-fact (name is-follower) (cf ?cf2)))
  =>
  (if (<= ?cf1 -0.4) 
      then
      (assert (a-fact (name likes-studying) (cf (* 0.5 (min ?cf1 ?cf2)))))
      (assert (a-fact (name likes-teaching) (cf (* 0.7 (min ?cf1 ?cf2)))))
      else (if (>= ?cf1 0.4)
            then (assert (a-fact (name is-active) (cf (* -0.3 (min ?cf1 ?cf2))))))))

(defrule rule6
  (a-fact (name q7) (cf ?cf1))
  =>
  (if (>= ?cf1 0.4) 
      then
      (assert (a-fact (name likes-studying) (cf (* 0.9 ?cf1))))
      (assert (a-fact (name likes-teaching) (cf (* 0.7 ?cf1))))))

(defrule rule7
  (a-fact (name q8) (cf ?cf1))
  =>
  (if (>= ?cf1 0.4) 
      then
      (assert (a-fact (name is-follower) (cf (* 0.9 ?cf1))))
      (assert (a-fact (name is-leader) (cf (* -0.9 ?cf1))))))

;;************************
;;* JOB SELECTION RULES
;;************************

;; Based on the infered facts these rules infer the best job

(defrule print-results
  (a-fact (name q1) (cf ?cf1))
  =>
  (printout  t "The recommended jobs for you are:" crlf)
  (printout  t crlf)
  (assert (finished)))

(defrule job-selection-rule-1
  (finished)
  (a-fact (name is-leader) (cf ?cf1))
  (a-fact (name is-social) (cf ?cf2))
  =>
  (if (>= (* 0.7 (min ?cf1 ?cf2)) 0.4) 
      then
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "Manager with cf " (* 0.7 (min ?cf1 ?cf2)) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf)))

(defrule job-selection-rule-2
  (finished)
  (a-fact (name is-social) (cf ?cf1))
  (a-fact (name is-leader) (cf ?cf2))
  (a-fact (name likes-teaching) (cf ?cf3))
  =>
  (if (>= (* 0.8 (min ?cf1 ?cf2 ?cf3)) 0.4)
      then 
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "Professor with cf " (* 0.8 (min ?cf1 ?cf2 ?cf3)) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf))))

(defrule job-selection-rule-3
  (finished)
  (a-fact (name likes-spending) (cf ?cf1))
  (a-fact (name likes-outdoor-activities) (cf ?cf2))
  (a-fact (name likes-sports) (cf ?cf3))
  =>
  (if (>= (* 0.9 (min ?cf1 ?cf2 ?cf3)) 0.4)
      then  
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "HR Manager with cf " (* 0.9 (min ?cf1 ?cf2 ?cf3)) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf)))

(defrule job-selection-rule-4
  (finished)
  (a-fact (name likes-indoor-activities) (cf ?cf1))
  (a-fact (name likes-studying) (cf ?cf2))
  (a-fact (name is-introvert) (cf ?cf3))
  (a-fact (name good-with-computers) (cf ?cf4))
  =>
  (if (>= (* 0.8 (min ?cf1 ?cf2 ?cf3 ?cf4)) 0.4)
      then 
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "Computer Programmer with cf " (* 0.8 (min ?cf1 ?cf2 ?cf3 ?cf4) ) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf)))

(defrule job-selection-rule-5
  (finished)
  (a-fact (name likes-indoor-activities) (cf ?cf1))
  (a-fact (name likes-studying) (cf ?cf2))
  (a-fact (name is-leader) (cf ?cf3))
  =>
  (if (>= (* 0.7 (min ?cf1 ?cf2 ?cf3)) 0.4)
      then  
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "Mathematician with cf " (* 0.7 (min ?cf1 ?cf2 ?cf3)) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf)))

(defrule job-selection-rule-6
  (finished)
  (a-fact (name is-leader) (cf ?cf1))
  (a-fact (name likes-studying) (cf ?cf2))
  =>
  (if (>= (* 0.8 (min ?cf1 ?cf2)) 0.4)
      then 
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "Architect with cf " (* 0.8 (min ?cf1 ?cf2)) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf)))

(defrule job-selection-rule-7
  (finished)
  (a-fact (name is-follower) (cf ?cf1))
  (a-fact (name likes-outdoor-activities) (cf ?cf2))
  =>
  (if (>= (* 0.9 (min ?cf1 ?cf2)) 0.4)
      then 
      (printout  t "------------------------------------------------------" crlf)
      (printout  t "Construction Worker with cf " (* 0.9 (min ?cf1 ?cf2)) crlf)
      (printout  t "------------------------------------------------------" crlf)
      (printout  t crlf)))

