PageCircus makes the use of the following libraries:

    BSJSONAdditions ()
    ObjectiveFlickr ()
    iText ()
    Barcode Generator (Jeff LaMarche)

To Do's:

2006-12-03: PETextBlock's color picker must be revised and reviewed with care.
Esp. the CMYK color issue.

Design considerations:

No output-control block injection when PEObject's are created. Only later
when calling -drawWithOutputControl are output-control blocks applied.
