# Tutorial for embedding KcsA #

KcsA is a transmembrane pore-forming channel, selective for potassium ions.
We have chosen it for this tutorial because of its conical transmembrane shape, representing special advantages for the protein embedding procedure:
to preserve correct lipid densities in both leaflet, a different number of lipids have to be removed.




---


## System requirements ##

For executing this tutorial one-to-one you need the following system configuration:
  * **Internet access**
  * **Linux** and a **Linux-Shell**, e.g. _Ubuntu Linux_ & `bash`
  * any **text editor**, e.g. `gedit`
  * **wget** (typically part of Linux)
  * **gunzip** (typically part of Linux)
  * the **sed** stream editor (typically part of Linux)
  * the **GROMACS 4.5.5** MD package
  * **LAMBADA** for membrane protein orientation and
  * **InflateGRO2** for protein embedding


---


## Protein preparation ##

**Download** the protein structure from the RCSB Protein Databank (PDB).
Since we want to simulate the protein in its physiological relevant tetrameric structure, we have to download the biological assembly:
```bash

wget "http://www.rcsb.org/pdb/files/1R3J.pdb1.gz"```

**Unpack** this archive and combine the subunits to one structure:
```bash

gunzip 1R3J.pdb1.gz
sed -e 's/ENDMDL.*//g;s/MODEL.*//g;/^$/d' <1R3J.pdb1 >1r3j.pdb```

**Extract** the protein and adjust the box dimensions:
```bash

echo q | make_ndx -f 1r3j.pdb -o 1r3j.ndx
echo "1 1" | editconf -f 1r3j.pdb -n 1r3j.ndx -o kcsa.pdb -d 2```


**Convert** the structure to the world of GROMACS:
```bash

echo 1 | pdb2gmx -f kcsa.pdb -p kcsa.top -i posre.kcsa -o kcsa.gro -ff gromos53a6 -missing
editconf -f kcsa.gro -o protein.gro -d 2```
For this tutorial we need to allow missing atoms using the `-missing` parameter.

**NOTE:** MD simulations work only if the protein structure is complete. This structure of KcsA is not. For a real setup you have to do additional steps to complete the structure (see the [GROMACS help](http://www.gromacs.org/Documentation/Errors#WARNING.3a_atom_X_is_missing_in_residue_XXX_Y_in_the_pdb_file) for this).

**Test** the generated system topology
```bash

touch empty.mdp
grompp -f empty.mdp -c 1bl8.gro -p kcsa.top -o test.tpr```



## Protein orientation & membrane alignment ##

**Orient** the protein using LAMBADA
```bash

~/lib/lambada/lambada_rc1/lambada -f1 kcsa.gro -f2 membrane.gro```
The combined model of protein and membrane is stored in the output file `prot_memb.gro`.



## Protein embedding ##

We use InflateGRO2 for **embedding** the protein in the membrane.
Since the membrane water molecules may disturb the embedding procedure, remove the water:
```bash

echo q | make_ndx -f prot_memb.gro -o prot_memb.ndx
echo 17 | editconf -f prot_memb.gro -n prot_memb.ndx -o  prot_memb.nowater.gro```


Copy the needed lipid ITP files and complete the topology by adding the lipids:
```bash

cp ../pope-popc/*.itp .
gedit kcsa.top```


Copy the MDP file supplied with InflateGRO2:
```bash

cp ~/lib/inflategro/inflategro2b9/deflate.mdp .```


Generate the group for inflating by combining both lipid types to one NDX group (group 13 = POPE, group 14 = POPC):
```bash

echo -e "13|14\nq" | make_ndx -f prot_memb.nowater.gro -o prot_memb.nowater.ndx```


To prevent surprises by running InflateGRO2's internal deflating routine, you should check the compatibility of the topology and coordinates:
```bash

grompp -f empty.mdp -c prot_memb.nowater.gro -p kcsa.top -o test2.tpr```
Errors might occur by having wrong numbers of atoms in the system.


If everything seems to work well run InflateGRO2:
```bash

~/lib/inflategro/inflategro2b9/inflategro2 -f prot_memb.nowater.gro -n prot_memb.nowater.ndx -p kcsa.top -m deflate.mdp -v```


Since InflateGRO2 switches off interactions of lipid molecules that do not overlap with the protein with any other system component, a final energy minimization step has to be executed, where each molecule can interact with any other molecule.
```bash

Add: ENERGY MINIMIZATION```



## Solvating the system ##

For biomolecular systems the typical solvent is water.
Use the GROMACS tool `genbox` to add it to your system:
```bash

genbox -cp embedded.gro -cs -p kcsa.top -o kcsa.inwater.gro```


Mimicking the intra-cellular environment, ions have to be added in a physiological relevant concentration:
```bash

touch empty.mdp
grompp -f empty.mdp -c kcsa.inwater.gro -p kcsa.top -o kcsa.inwater.tpr
genion -f kcsa.inwater.tpr -p kcsa.top -o kcsa.withions.gro```


## Membrane equilibration ##