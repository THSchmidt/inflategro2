# Tutorial for embedding TolC #

The _E. coli_ outer membrane exit duct TolC is an essential part of antimicrobial drug resistance mechanisms since it forms a continuous channel, which allows a direct efflux of transported substrates by other proteins (e.g. AcrB) from the periplasm to the cell exterior.
TolC has been chosen for this tutorial because of its weak conical transmembrane shape which is critical in preserving optimal lipid densities in both bilayer leaflets during the embedding procedure.





---


## System requirements ##

For executing this tutorial one-to-one you need the following system configuration:
  * **Internet access**
  * **Linux** and a **Linux-Shell**, e.g. _Ubuntu Linux_ & `bash`
  * any **text editor**, e.g. `gedit`
  * **wget** (typically part of Linux)
  * the **sed** stream editor (typically part of Linux)
  * the **GROMACS 4.5.5** MD package
  * the GROMOS96 54a7 parameter set
  * **LAMBADA** for membrane protein orientation and
  * **InflateGRO2** for protein embedding


---


## Protein preparation ##

**Download** the TolC structure `[1]` from the RCSB Protein Databank (PDB):
```bash

wget "http://www.rcsb.org/pdb/download/downloadFile.do?fileFormat=pdb&compression=NO&structureId=1EK9" -O 1ek9.pdb```


**Prepare** the structural data by replacing amino acids that may lead to problems when assigning the force field parameters.
In the case of TolC we have to replace MSE (Selenomethionine) by its "parent" residue MET (Methionine). This includes replacement of the residue name and a corresponding atom type:
```bash

sed 's/MSE/MET/g' 1ek9.pdb > temp1.pdb
sed 's/ SE / SD /g' temp1.pdb > temp2.pdb && mv temp2.pdb tolc.pdb && rm temp1.pdb```


**Extract** the protein (remove crystal water) and adjust the box dimensions:
```bash

echo q | make_ndx -f tolc.pdb -o 4extraction.ndx
echo "1 1" | editconf -f tolc.pdb -n 4extraction.ndx -o tolc.nowater.pdb -d 2```


**Convert** the structure to the world of GROMACS (select the recommended SPC as water model):
```bash

echo 1 | pdb2gmx -f tolc.nowater.pdb -p tolc.top -i posre.tolc -o tolc.gro -ff gromos54a7```



## Bilayer preparation ##

**Download** the pre-equilibrated bilayer patch and corresponding force field parameters from the ATB website `[2]`:
```bash

wget "http://compbio.biosci.uq.edu.au/atb/download.py?molid=1506&file=rtp_uniatom" -O popc.ori.itp
wget "http://compbio.biosci.uq.edu.au/atb/download.py?boxid=31&file=box_gro" -O popc.ori.gro```


**Prepare** the structural data by replacing residue names and atom types that may lead to problems when assigning the force field parameters or running InflateGRO2:
```bash

sed 's/P,SI/   P/g' popc.ori.itp > popc.itp
sed 's/POP /POPC/g' popc.ori.gro > popc.gro```






**Duplicate** the membrane bilayer along the two dimensions of the bilayer plane:
```bash

genconf -f popc.gro -o membrane.gro -nbox 2 2 1```




## Protein orientation & membrane alignment ##

**Orient** the protein using LAMBADA
```bash

~/lib/lambada/lambada_rc1/lambada -f1 tolc.gro -f2 membrane.gro```
The combined model of protein and membrane is stored in the output file `prot_memb.gro`.


**Update** the topology (manually) by adding the bilayer to the TOP file:
```bash

gedit tolc.top```
A line linking to the ITP file is needed (set it below the chain ITP links):
```bash

#include "popc.itp"```
and a line of the number of lipids:
```bash

POPC       512```




## Protein embedding ##

InflateGRO2 is used for embedding the protein in the membrane.
**Remove all water molecules** since they may disturb the embedding procedure and generate another (compatible) NDX file without water:
```bash

echo q | make_ndx -f prot_memb.gro -o prot_memb.ndx
echo 16 | editconf -f prot_memb.gro -n prot_memb.ndx -o  prot_memb.nowater.gro
echo q | make_ndx -f prot_memb.nowater.gro -o prot_memb.nowater.ndx```
Selecting the GROMACS 4.5.5 default NDX group "16" means "everything but water".



**Test** the compatibility of the generated coordinates and topology (optionally).
Using the given POPC lipids may lead to a warning of wrong atom names when grompp combines coordinates and topology. This is because of an unordered numbering in the used ITP file (CN2, CN3, CN1) instead of (CN1, CN2, CN3) in the GRO file. We ignore this using the "-maxwarn 1" option of mdrun since all relevant atoms are of the same type.
```bash

touch empty.mdp
grompp -f empty.mdp -c prot_memb.nowater.gro -p tolc.top -o test.tpr -maxwarn 1```
Clean up if everything works.
```bash

rm test.tpr mdout.mdp empty.mdp```
Take a coffee and try again after bugfixing if not.


**Copy** the MDP file for the iterative energy minimization steps supplied with InflateGRO2:
```bash

cp ~/lib/inflategro/inflategro2b9/deflate.mdp .```


**Run** InflateGRO2:
```bash

~/phd/lib/inflategro2/inflategro2 -f prot_memb.nowater.gro -n prot_memb.nowater.ndx -p tolc.top -m deflate.mdp -v```
Since InflateGRO2 specifically turns off interactions of system components, a final, regular energy minimization should be executed without any energy exclusions, where each atom is allowed to "see" its neighbors (only dependent on the force field parameter set of choice).



## Solvating the system ##

For biomolecular systems the typical solvent is water.
Use the GROMACS tool `genbox` to add it to your system:
```bash

genbox -cp shrink.20.gro -cs -p tolc.top -o tolc.inwater.gro```


Mimicking the intra-cellular environment, ions have to be added in a physiological relevant concentration:
```bash

touch empty.mdp
grompp -f empty.mdp -c tolc.inwater.gro -p tolc.top -o tolc.inwater.tpr
genion -f tolc.inwater.tpr -p tolc.top -o tolc.withions.gro```




## Equilibration steps ##

We recommend a short NVT run of 500 ps to solvate protein and lipid headgroups before executing a membrane equilibration (NPT, semi-isotropic) of 20 ns.
For both equilibration steps the protein coordinates should be fixed using C-alpha position restraints of 1000 kJ mol<sup>-1</sup> nm<sup>-2</sup>.


# References #
`[1]` Koronakis, V., A. Sharff, E. Koronakis, B. Luisi, und C. Hughes. „Crystal structure of the bacterial membrane protein TolC central to multidrug efflux and protein export“. Nature 405, Nr. 6789 (2000): 914–919.

`[2]` Malde, Alpeshkumar K., Le Zuo, Matthew Breeze, Martin Stroet, David Poger, Pramod C. Nair, Chris Oostenbrink, und Alan E. Mark. „An Automated Force Field Topology Builder (ATB) and Repository: Version 1.0“. J. Chem. Theory Comput. 7, Nr. 12 (2011): 4026–4037.