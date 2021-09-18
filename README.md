# Modest-vocabulary loop-closure detection with incremental bag of tracked words

This open source MATLAB algorith presents an appearance-based loop-closure detection pipeline, which encodes the traversed trajectory by unique visual words generated online through tracking.
The incrementally constructed visual vocabulary is referred to as “Bag of Tracked Words”.
By querying the database through a nearest neighbor voting scheme, probabilistic scores are assigned to all visited locations.
Exploiting the inherent time order appearing in the loop-closure task, the produced scores are processed through a Bayesian filter to estimate the belief state about the robot’s location on the map.
Furthermore, a temporal consistency constraint reduces the searching space, while a geometrical verification step rectifies further the results.
Management is also applied to the resulting vocabulary to lessen its tendency to exceed in size over time, while it constrains the system’s computational complexity and voting ambiguity.
The performance of the proposed approach is experimentally evaluated on several challenging and publicly available datasets, including hand-held, car-mounted, aerial and ground robot courses.
Results demonstrate the method’s adaptability, reaching high recall rates for perfect precision and outperforming most of the compared state-of-the-art algorithms.
The system’s effectiveness is owed to the reduced vocabulary size, which, compared to the ones of other contemporary pipelines, is at least one order of magnitude smaller.
An open research-oriented source code has been made publicly available, which is dubbed as “**BoTW-LCD**”.

Note that the HMM-BoTW approach is a research code. The authors are not responsible for any errors it may contain. **Use it at your own risk!**

## Conditions of use
BoTW-LCD is distributed under the terms of the [MIT License](https://github.com/ktsintotas/HMM-BoTW/blob/master/LICENSE).

## Related publication
The details of the algorithm are explained in the [following publication](https://www.sciencedirect.com/science/article/pii/S0921889021000671): 

**Modest-vocabulary loop-closure detection with incremental bag of tracked words<br/>**
Konstantinos A. Tsintotas, Loukas Bampis, and Antonios Gasteratos<br/>
Robotics and Autonomous Systems (Elsevier)

If you use this code, please cite:

```
@article{tsintotas2021botw,
  title={Modest-vocabulary loop-closure detection with incremental bag of tracked words},  
  author={K. A. Tsintotas and L. Bampis and A. Gasteratos},   
  journal={Robotics and Autonomous Systems},
  pages={103782},
  volume={141},
  year={2021},   
  month={July},
  publisher={Elsevier},
  doi={10.1016/j.robot.2021.103782}
}
```

## Contact
If you have problems or questions using this code, please contact the author (e-mail address: ktsintot@pme.duth.gr, ktsintotas@icloud.com). Contributions are totally welcome.
