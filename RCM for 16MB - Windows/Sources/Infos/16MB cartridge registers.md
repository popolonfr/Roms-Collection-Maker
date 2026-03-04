\## Table des resgistres



| NOM DU REGISTRE      | MODE |ADRESSE ( S )| B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |

|:---------------------|:----:|:-----------:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|

| Offset\_L             |   w  |    3800h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Offset\_H             |   w  |    3801h    |    |    |    |    |    | 10 |  9 |  8 |

| Offset    (2 Mo)     |   w  |    3FFFh    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Operating\_Mode       |   w  |    3804h    |    |    |    |    |    |    |  M |  R |

|\*\*Kon\_DAC\_Out\*\* (1)   |   w  |    4000h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

|\*\*Kon\_DAC\_Ctrl\*\* (2)  |   w  |    98FBh    |    |    |    |  D |    |    |    |    |

| \*\*DAC\_Output\*\* (2)   |   w  |    98FCh    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |



\###### (1) Le mode Konami DAC doit être sélectionné: (2) le segment 3Fh en plage 2 doit être sélectionné



| NOM DU REGISTRE      | MODE |ADRESSE ( S )| B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |

|:---------------------|:----:|:-----------:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|

| Map0\_L               |   w  |    5000h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| \*\*Map0\_H\*\* (3)       |   w  |    5001h    |    |    |    |    |    | 10 |  9 |  8 |

| Map1\_L               |   w  |    7000h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| \*\*Map1\_H\*\* (3)       |   w  |    7001h    |    |    |    |    |    | 10 |  9 |  8 |

| Map2\_L               |   w  |    9000h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| \*\*Map2\_H\*\* (3)       |   w  |    9001h    |    |    |    |    |    | 10 |  9 |  8 |

| Map3\_L               |   w  |    B000h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| \*\*Map3\_H\*\* (3)       |   w  |    B001h    |    |    |    |    |    | 10 |  9 |  8 |



\###### (3) Le mode 16 bits doit être sélectionée. Ce mode n'existe pas sur la cartouche destinée aux collections de Rom



| NOM DU REGISTRE      | MODE |ADRESSE ( S )| B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |

|:---------------------|:----:|:-----------:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|

| Waveform\_Ch1         |  r/w | 9800h~981Fh |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Waveform\_Ch2         |  r/w | 9820h~983Fh |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Waveform\_Ch3         |  r/w | 9840h~985Fh |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Waveform\_Ch4 (4)     |  r/w | 9860h~987Fh |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Frequency\_Ch1\_L      |   w  |    9880h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Frequency\_Ch1\_H      |   w  |    9881h    |    |    |    |    | 11 | 10 |  9 |  8 |

| Frequency\_Ch2\_L      |   w  |    9882h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Frequency\_Ch2\_H      |   w  |    9883h    |    |    |    |    | 11 | 10 |  9 |  8 |

| Frequency\_Ch3\_L      |   w  |    9884h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Frequency\_Ch3\_H      |   w  |    9885h    |    |    |    |    | 11 | 10 |  9 |  8 |

| Frequency\_Ch4\_L      |   w  |    9886h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Frequency\_Ch4\_H      |   w  |    9887h    |    |    |    |    | 11 | 10 |  9 |  8 |

| Frequency\_Ch5\_L      |   w  |    9888h    |  7 |  6 |  5 |  4 |  3 |  2 |  1 |  0 |

| Frequency\_Ch5\_H      |   w  |    9889h    |    |    |    |    | 11 | 10 |  9 |  8 |

| Volume\_Ch1           |   w  |    988Ah    |    |    |    |    |  3 |  2 |  1 |  0 |

| Volume\_Ch2           |   w  |    988Bh    |    |    |    |    |  3 |  2 |  1 |  0 |

| Volume\_Ch3           |   w  |    988Ch    |    |    |    |    |  3 |  2 |  1 |  0 |

| Volume\_Ch4           |   w  |    988Dh    |    |    |    |    |  3 |  2 |  1 |  0 |

| Volume\_Ch5           |   w  |    988Eh    |    |    |    |    |  3 |  2 |  1 |  0 |

| Enable\_Channel       |   w  |    988Fh    |    |    |    | C5 | C4 | C3 | C2 | C1 |



\###### Note: Le registre de teste de l'SCC n'est pas implémenté : (4) Le canal 5 partage la forme d'onde du canal 4



| NOM DU REGISTRE      | MODE |ADRESSE ( S )|  B7 |  B6 |  B5 |  B4 |  B3 |  B2 |  B1 |  B0 |

|:---------------------|:----:|:-----------:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|

| Flash\_STA\_Off (5)    |   w  |    4x10h    |\*`1`\*|\*`1`\*|\*`1`\*|\*`1`\*|\*`0`\*|\*`0`\*|\*`0`\*|\*`0`\*|

| Flash\_CMD\_1st (5)    |   w  |    4xAAh    |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |

| Flash\_CMD\_2nd (5)    |   w  |    4x55h    |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |



| NOM DU REGISTRE      | MODE |ADRESSE ( S )|  B7 |  B6 |  B5 |  B4 |  B3 |  B2 |  B1 |  B0 |

|:---------------------|:----:|:-----------:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|

| Flash\_STA\_Off (5)    |   w  |    4x10h    |\*`1`\*|\*`1`\*|\*`1`\*|\*`1`\*|\*`0`\*|\*`0`\*|\*`0`\*|\*`0`\*|

| Flash\_CMD\_1st (5)    |   w  |    4555h    |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |

| Flash\_CMD\_2nd (5)    |   w  |    4255h    |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |



\###### (5) inaccessible en mode Konami DAC

