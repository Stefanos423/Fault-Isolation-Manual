(deffacts startup (menu-op start))
	(member-of possible-main-menu-selections 1 2 3 4 5 6 7 8)
	(defrule main-menu
 	(menu-op start)
 	?fact <- (menu-op start)
 	=>
 	(printout t t t t "*****BOEING 747 FAULT ISOLATION EXPERT SYSTEM*****" crlf)
 	(printout t t "MAIN MENU" t crlf)
 	(printout t "1 - Oil consumption is high" crlf)
 	(printout t "2 - Oil quantity indicator is malfunctioning" crlf)
 	(printout t "3 - Oil pressure is abnormal or indicator is malfunctioning" crlf)
 	(printout t "4 - Oil filter bypass light is illuminated" crlf)
 	(printout t "5 - Oil temperature is abnormal or indicator is malfunctioning" crlf)
	(printout t "6 - Breather temperature is high" crlf)
	(printout t "7 - Engine was shutdown in flight" crlf)
	(printout t "8 - Unlisted engine oil fault" crlf)
	(printout t t "Which of the above were observed during the flight? > ")
	(assert (observed-problem-number (read)))
	(printout t crlf)
	(retract ?fact)
)

(defrule engine-number
	(menu-op engine-num)
	?fact <- (menu-op engine-num)
	=>
	(printout t "Which engine is malfuctioning? (1,2,3,4,0) > ")
	(assert (engine-num (read)))
	(printout t crlf)
	(retract ?fact)
)

(defrule oil-consumption
	(observed-problem-number 1)
	=>
	(assert (observed-problem-name high_consumption))
	(assert (menu-op engine-num))
) 

(defrule high-oil-consumption
	(observed-problem-name high_consumption)
	(engine-num ?entry)
	=>
	(assert (error-code (sym-cat 79-01-Bx-0 ?entry)))
	(printout t "Are there any other abnormal oil systems? [yes,no] > " )
	(assert (oil-systems (read)))
)

(defrule high-oil-consumption-abnormal
	(oil-systems yes)
	(engine-num ?entry)
	=>
	(assert (error-code (sym-cat 79-01-BE-0 ?entry)))
	(printout t "Eng " ?entry " oil consumption high, with other oil sys ind abnorm. (Record Data)" crlf)
)

(defrule high-oil-consumption-normal
	(oil-systems no)
	(engine-num ?entry)
	=>
	(assert (error-code (sym-cat 79-01-BD-0 ?entry)))
	(printout t "Eng " ?entry " oil consumption high, all other oil sys ind norm. (Record Data)" crlf)
)

(defrule oil-pressure
	(observed-problem-number 3)
	=>
	(assert (observed-problem-name abnormal_oil_pressure))
	(assert (menu-op engine-num))
)

(defrule abnormal-oil-pressure
	(observed-problem-name abnormal_oil_pressure)
	(engine-num ?entry)
	=>
	(assert (error-code (sym-cat 79-01-Cx-0 ?entry)))
	(printout t "Change thrust setting & check oil press. Did oil press follow thrust change? [yes,no] > " )
	(assert (oil-press (read)))
)

(defrule oil-press-followed
	(oil-press yes)
	(engine-num ?entry)
	=>
	(assert (error-code (sym-cat 79-01-CE-0 ?entry)))
	(printout t "Eng " ?entry " oil press (low, high, fluctuating, in yellow band).  Press follows thrust setting change." crlf)
)

(defrule oil-press-not-followed
	(oil-press no)
	(engine-num ?entry)
	=>
	(assert (error-code (sym-cat 79-01-CD-0 ?entry)))
	(printout t "Eng " ?entry " oil press (low, high, fluctuating, in yellow band).  Remains constant with thrust setting change." crlf)
)

(defrule BD-BE-fault
	(engine-num ?entry)
	(or (error-code 79-01-BD-00)
	    (error-code 79-01-BD-01)
	    (error-code 79-01-BD-02)
	    (error-code 79-01-BD-03)
	    (error-code 79-01-BD-04)
	    (error-code 79-01-BE-00)
	    (error-code 79-01-BE-01)
	    (error-code 79-01-BE-02)
	    (error-code 79-01-BE-03)
	    (error-code 79-01-BE-04))
	=>
	(printout t "Examine turbine exhaust area for evidence of oil loss per Visual Check 1, 79-01-10.  Is oil loss occuring? [yes,no] > ")
	(assert (oil-loss (read)))
)

(defrule oil-loss-occuring
	(oil-loss yes)
	=>
	(printout t "Identify source of oil loss per Visual Check 1, 79-01-10.  Is oil loss due to leakage from rear cover of No. 4 bearing compartment? [yes,no] > ")
	(assert (supply-line (read)))
)

(defrule no-supply-line
	(supply-line no)
	=>
	(printout t "Is oil loss due to leakage from oil pressure supply line or oil scavenge line of No. 4 bearing compartment? [yes,no] > ")
	(assert (scavenge-line (read)))
)

(defrule yes-supply-line
	(supply-line yes)
	=>
	(printout t "Replace engine.  MM 71-00-02" crlf)
)

(defrule yes-scavenge-line
	(scavenge-line yes)
	=>
	(printout t "Remove and clean or replace oil pressure supply tube and/or oil scavenge tube as required.  MM 72-53-00." crlf)
)

(defrule no-scavenge-line
	(scavenge-line no)
	=>
	(printout t "Is oil loss due to a clogged or loose oil scavenge line or a failed scavenge pump? [yes,no] > ")
	(assert (clogged (read)))
)

(defrule yes-clogged
	(clogged yes)
	=>
	(printout t "Remove and clean or replace oil scavenge tube as necessary.  MM 72-53-00.  Replace scavenge pump if required.  MM 72-61-21" crlf)
)

(defrule no-clogged
	(clogged no)
	=>
	(printout t "Replace engine.  MM 71-00-02" crlf)
)

(defrule no-oil-loss-occuring
	(oil-loss no)
	=>
	(printout t "Examine main gearbox drains (MM 71-71-00) for leakage.  Is excessive oil present? [yes,no] > ")
	(assert (excess-oil (read)))
)

(defrule yes-excess-oil
	(excess-oil yes)
	=>
	(printout t "Identify leaking drain line source (MM 71-71-00) Was source of leakage from the fuel/oil cooler? [yes,no] > ")
	(assert (cooler (read)))
)

(defrule yes-cooler
	(cooler yes)
	=>
	(printout t "Replace fuel/oil cooler (MM 79-21-01)" crlf)
)

(defrule no-cooler
	(cooler no)
	=>
	(printout t "Remove applicable component and check both component and drive pad seal.  Replace component and/or drive seal as follows:
        Component           Seal Replacement Ref
        ---------           --------------------
 Generator (MM 24-21-01)        MM 72-61-08
 Fuel Pump (MM 73-11-01)        MM 72-61-11
 Hydraulic Pump (MM 29-11-05)   MM 72-61-09
 Starter (MM 80-11-01)          MM 72-61-06
 Constant Speed Drive           MM 72-61-07
 (MM 24-11-01)" crlf)
)

(defrule no-excess
	(excess-oil no)
	=>
	(printout t "Check that PT3 water drain plug is installed per Visual Check 9, 71-01-10.  Is plug missing? [yes,no] > ")
	(assert (missing (read)))
)

(defrule yes-missing
	(missing yes)
	=>
	(printout t "Install drain plug." crlf)
)

(defrule no-missing
	(missing no)
	=>
	(printout t "Examine external plumbing, main gearbox and angle gearbox for obvious leakage per Visual Check 2, 79-01-10.  Is obvious leakage present? [yes,no] > ")
	(assert (obvious (read)))
)

(defrule yes-obvious
	(obvious yes)
	=>
	(printout t "Is leakage from oil pressure and/or oil scavenge lines? [yes,no] > ")
	(assert (oil-presss (read)))
)

(defrule yes-oil-press
	(oil-presss yes)
	=>
	(printout t "Is leakage from No. 3 bearing oil scavenge tube connections? [yes,no] > ")
	(assert (three (read)))
)

(defrule (yes-three
	(three yes)
	=>
	(printout t "Repair No. 3 bearing oil scavenge tube connections as required.  MM 79-21-03 AR." crlf)
)

(defrule no-three
	(or (three no)
	    (man no)
	    (instr 1)
	    (instr 5))
	=>
	(printout t "Replace Engine.  MM 71-00-02" crlf)
)

(defrule no-oil-press
	(oil-presss no)
	=>
	(printout t "Is leakage from breather lines? [yes,no] > ")
	(assert (breath (read)))
)

(defrule yes-breath
	(breath yes)
	=>
	(printout t "Is leakage from No. 1 and 2 bearing breather manifold and/or No. 3 bearing breather manifold? [yes,no] > ")
	(assert (man (read)))
)

(defrule yes-man
	(man yes)
	=>
	(printout t "Replace No. 1 and 2 bearing breather manifold and/or No. 3 bearing breather manifold as required.  MM 79-21-04 R/I." crlf)
)

(defrule no-breath
	(breath no)
	=>
	(printout t "Identify the source of the leakage." crlf)
	(printout t "1 - Oil instrumentation lines" crlf)
	(printout t "2 - N2 manual crank on main gearbox" crlf)
	(printout t "3 - Angle gearbox" crlf)
	(printout t "4 - Main gearbox" crlf)
	(printout t "5 - None of the above" crlf)
	(printout t "> ")
	(assert (instr (read)))
)


(defrule yes-crank
	(instr 2)
	=>
	(printout t "Remove N2 manual crank pad and install new o-ring and gasket (if applicable).  MM 72-00-00 MP." crlf)
)

(defrule yes-angle
	(instr 3)
	=>
	(printout t "Replace angle gearbox.  MM 72-61-01 R/I." crlf)
)

(defrule yes-main
	(instr 4)
	=>
	(printout t "Replace main gearbox.  MM 72-61-02 R/I." crlf)
)

(defrule no-obvious
	(obvious no)
	=>
	(printout t "Perform oil system static leak check per Engine Check 1, 79-01-20 and/or oil system monitoring leak check per Engine Check 2, 79-01-20.  Was source of leakage found? [yes,no] > ")
	(assert (source (read)))
)

(defrule yes-source
	(source yes)
	=>
	(printout t "Refer to Engine Check 1 and/or engine check 2 for corrective action." crlf)
)

(defrule no-source
	(source no)
	=>
	(printout t "Check fuel pump hydraulic stage pressure per Engine Check 2, 71-01-20.  Is pressure within limits? [yes,no] > ")
	(assert (limits (read)))
)

(defrule no-limits
	(limits no)
	=>
	(printout t "Replace fuel pump.  MM 73-11-01." crlf)
)

(defrule yes-limits
	(limits yes)
	=>
	(printout t "Check ground idle speed.  MM 71-00-00 A/T, Test No. 9.  Is ground idle speed low? [yes,no] > ")
	(assert (low (read)))
)

(defrule yes-low
	(low yes)
	=>
	(printout t "Adjust ground idle speed.  MM 71-00-00 A/T, Test No. 9." crlf)
)

(defrule no-low
	(low no)
	=>
	(printout t "From idle power, advance thrust level slowly to increase N2 RPM by 10+ACU-.  Did N1 increase at least 10+ACU- also? [yes,no] > ")
	(assert (increase (read)))
)

(defrule yes-increase
	(increase yes)
	=>
	(printout t "The following are infrequent causes of this fault:
 1. Faulty main gearbox deaerator          Ref Engine Check 3, 79-01-20 for resolution
 2. PT3 manifold leaks                     Ref Visual Check 8, 71-01-10 for resolution
 3. No. 1 and 2 bearing compartment leaks  Replace Engine (MM 71-00-02)" crlf)
)

(defrule no-increase
	(increase no)
	=>
	(printout t "Replace Evc.  MM 75-31-01." crlf)
)

(defrule CD-fault
	(or (error-code 79-01-CD-00)
	    (error-code 79-01-CD-01)
	    (error-code 79-01-CD-02)
	    (error-code 79-01-CD-03)
	    (error-code 79-01-CD-04))
	=>
	(printout t "Connect line for air pressure to elbow of oil pressure transmitter, T422.  Apply 45 PSI.  Does indicator read 40 to 45 PSI? [yes,no] > ")
	(assert (psi (read)))
)

(defrule yes-psi
	(psi yes)
	=>
	(printout t "Adjust oil pressure.  MM 71-00-00 A/T, Test No. 7.  Observe oil pressure indicator.  Is oil pressure within limits? [yes,no] > ")
	(assert (itis (read)))
)

(defrule yes-it-is
	(itis yes)
	=>
	(printout t "The following item may be an infrequent cause of abnormal oil pressure:
  Main Oil Pump - Replace main oil pump (MM 72-61-17)" crlf)
)

(defrule no-it-is
	(itis no)
	=>
	(printout t "Replace oil pressure regulating valve.  MM 72-61-03." crlf)
)

(defrule no-psi
	(or (psi no)
	    (mag no))
	=>
	(printout t "Exchange oil pressure indicators, N30, N31, N32, or N33.  MM 79-32-03.  Apply 40 to 45 PSI to transmitter.  Does indicator read 40 to 45 PSI? [yes,no] > ")
	(assert (still (read)))
)

(defrule yes-still
	(still yes)
	=>
	(printout t "Replace indicator.  MM 79-32-03." crlf)
)

(defrule no-still
	(still no)
	=>
	(printout t "Replace engine oil pressure transmitter, T422.  MM 79-32-01." crlf)
)

(defrule CE-fault
	(or (error-code 79-01-CE-00)
	    (error-code 79-01-CE-01)
	    (error-code 79-01-CE-02)
	    (error-code 79-01-CE-03)
	    (error-code 79-01-CE-04))
	=>
	(printout t "Examine magnetic chip detectors and mail oil strainer per Engine Check 18, 71-01-20.  Was contamination abnormal? [yes,no] > ")
	(assert (mag (read)))
)

(defrule yes-mag
	(mag yes)
	=>
	(printout t "Replace main oil strainer.  MM 72-61-05.  Replace main oil pressure regulating valve.  MM 72-61-03.  Perform oil system contamination inspection.  MM 72-00-00 I/C." crlf)
)
