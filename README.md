# <br/>Are 50K Words Enough for Place Recognition? A <br/> Visual Loop-Closure Detection Paradigm Using Incremental Bag of Tracked Words

This open source MATLAB algorith presents an appearance-based loop-closure detection pipeline, which encodes the traversed trajectory by unique visual words generated on-line by a tracking technique. The incrementally constructed visual vocabulary is referred to as “Bag of Tracked Words”. By querying the database through a nearest neighbor voting scheme, probabilistic scores are assigned to each visited location. Exploiting the temporal coherency presented in the loop-closure task, the produced scores are processed through a Bayesian filter to estimate the belief state about the robot’s location on the map. Furthermore, a temporal consistency constrain reduces the searching space, while a geometrical verification step consolidates the results. Vocabulary management is also applied at loop-closure events lessening its increasing size over time, as well as the system’s computational complexity and voting ambiguity. The performance of the proposed approach is experimentally evaluated on several challenging and publicly available datasets, including hand-held, car-mounted, aerial, and ground robot sequences. Results demonstrate the method’s adaptability, reaching high recall rates for perfect precision and outperforming most of the compared state-of-the-art algorithms. The system’s effectiveness is owed to the reduced vocabulary size, which, compared to the ones of other contemporary pipelines, is at least one order of magnitude shorter. An open researchoriented source code has been made publicly available, which is dubbed as “**HMM-BoTW**”.

Note that the HMM-BoTW approach is a research code. The authors are not responsible for any errors it may contain. **Use it at your own risk!**

## Conditions of use
HMM-BoTW is distributed under the terms of the [MIT License](https://github.com/ktsintotas/HMM-BoTW/blob/master/LICENSE).

## Related publication
The details of the algorithm are explained in the [following publication](https://ieeexplore.ieee.org/document/):

**Are 50K Words Enough for Place Recognition? A Visual Loop-Closure Detection Paradigm Using Incremental Bag of Tracked Words<br/>**
Konstantinos A. Tsintotas, Loukas Bampis, and Antonios Gasteratos<br/>
IEEE Transaction on Robotics, Vol. , No. , Pgs.  (Month 2020)

If you use this code, please cite:

```
@ARTICLE{tsintotas2019probabilistic,
  title={Probabilistic Appearance-Based Place Recognition Through Bag of Tracked Words},  
  author={K. A. Tsintotas and L. Bampis and A. Gasteratos},   
  journal={IEEE Transaction on Robotics},
  volume={},
  number={},
  pages={},
  year={},   
  month={}, 
  doi={}  
}
```
## Contact
If you have problems or questions using this code, please contact the author (ktsintot@pme.duth.gr). Ground truth requests and contributions are totally welcome.
