![http://inflategro2.googlecode.com/files/inflategro2_logo.png](http://inflategro2.googlecode.com/files/inflategro2_logo.png)

# Automatic embedding of protein structures into membranes #

**InflateGRO2** enables a full automated membrane protein embedding into pre-equilibrated lipid bilayer patches for MD simulation setup.


## Features ##
  * Keep as most as possible of lipid conformations of the pre-equilibrated patch:
    * expand only protein-overlapping lipids (dynamic component)
    * translate these lipids only as much as needed to solve all protein overlaps
    * for the integrated deflating procedure
      * freeze the rest (static component)
      * switch off interactions between the dynamic component and static lipids (not between the dynamic component and protein)
  * Keep correct lipid densities:
    * exact calculation of the number of lipids that should be deleted to preserve the initial packing density by an accurate calculation of the area occupied by protein
  * Increased flexibility for protein embedding...
    * ...into mixed bilayers
    * ...of MARTINI CG models
    * ...into multiple bilayers


## News ##

_2012-09-28_ The first release of InflateGRO2 is available for download.


## Quick start ##
  * Download and unpack the InflateGRO2 archive
  * Copy the folder to your lib directory (e.g. `cp -r inflategro2/ ~/lib`)
  * Make InflateGRO2 executable (e.g. `chmod 755 ~/lib/inflategro2/inflategro2`)
  * Set a soft link in your `bin` directory to the InflateGRO2 executable (e.g. `ln -s ~/lib/inflategro2/inflategro2 ~/bin/inflategro2`)

You can run InflateGRO2 by typing
```bash
inflategro2 -f protein.gro -p prot_memb.top -n prot_memb_groups.ndx -m deflate.mdp```

Get the program help by typing
```bash
inflategro2 -h```


## Documentation ##

We provide **[installation instructions](Installation.md)** and some **[tutorials](ExampleApplications.md)** on this program's project page.


## References ##
If you use InflateGRO2 for **publication**, please cite

> Schmidt, T. H. & Kandt, C. LAMBADA & InflateGRO2: Efficient Membrane Alignment and Insertion of Membrane Proteins for Molecular Dynamics Simulations. J. Chem. Inf. Model. (2012).doi:10.1021/ci3000453


**Electronic documents** should include a direct link to the InflateGRO2 hosting page:

> http://code.google.com/p/inflategro2


For **posters** or nerds we provide a QR Code, referencing to this Google Project Page:

  * [QR Code 96dpi](http://code.google.com/p/inflategro2/downloads/detail?name=inflategro2_qr96dpi.png)
  * [QR Code 300dpi](http://code.google.com/p/inflategro2/downloads/detail?name=inflategro2_qr300dpi.png)


## Related projects ##

  * http://code.google.com/p/lambada-align
  * http://code.google.com/p/squaredance
  * http://code.google.com/p/dxtuber