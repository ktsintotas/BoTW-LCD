# Modest-Vocabulary Visual Loop-Closure Detection Pipeline Using Incremental Bag of Tracked Words

This open source MATLAB algorith presents an appearance-based loop-closure detection pipeline, which encodes the traversed trajectory by unique visual words generated online through tracking. The incrementally constructed visual vocabulary is referred to as “Bag of Tracked Words”. By querying the database through a nearest neighbor voting scheme, probabilistic scores are assigned to all visited locations. Exploiting the inherent time order appearing in the loop-closure task, the produced scores are processed through a Bayesian filter
to estimate the belief state about the robot’s location on the map. Furthermore, a temporal consistency constraint reduces the searching space, while a geometrical verification step rectifies further the results. Management is also applied to the resulting vocabulary to lessen its tendency to exceed in size over time, while it constrains the system’s computational complexity and voting ambiguity. The performance of the proposed approach is experimentally evaluated on several challenging and publicly available datasets, including hand-held, car-mounted, aerial and ground robot courses. Results demonstrate the method’s adaptability, reaching high recall rates for perfect precision and outperforming most of the compared state-of-the-art algorithms. The system’s effectiveness is owed to the reduced vocabulary size, which, compared to the ones of other contemporary pipelines, is at least one order of magnitude smaller. An open research-oriented source code has been made publicly available, which is dubbed as “**HMM-BoTW**”.

Note that the HMM-BoTW approach is a research code. The authors are not responsible for any errors it may contain. **Use it at your own risk!**

## Conditions of use
HMM-BoTW is distributed under the terms of the [MIT License](https://github.com/ktsintotas/HMM-BoTW/blob/master/LICENSE).

## Related publication
The details of the algorithm are explained in the [following publication](https://ieeexplore.ieee.org/document/):

**Modest-Vocabulary Visual Loop-Closure Detection Pipeline Using Incremental Bag of Tracked Words<br/>**
Konstantinos A. Tsintotas, Loukas Bampis, and Antonios Gasteratos<br/>
Under review in IEEE Transaction on Robotics 

## Contact
If you have problems or questions using this code, please contact the author (ktsintot@pme.duth.gr). Ground truth requests and contributions are totally welcome.
