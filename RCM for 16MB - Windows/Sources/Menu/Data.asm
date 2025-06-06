; ROM List format is ROM segment, MSX generation (0=MSX1, 1=MSX2, etc), "Rom name" (40 characters)
;
; Add 128 to the MSX generation value to specify the last Rom from the list
;  This is a flag to prevent the cursor from exiting the list.
;  Be careful because the last Rom is not everytime the same. It depends on
;  The MSX generation used and the MSX generation supported by the ROMs.
;  Be sure to add 128 to each latest Rom which should be displayed depending on
;  the generation of the MSX used. (For example, the ROMs for MSX2 are not
;  displayed on MSX1 computers.


