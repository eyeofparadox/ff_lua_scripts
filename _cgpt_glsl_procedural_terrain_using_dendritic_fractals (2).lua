-- <?> 3.15.2023»01:57

Generating procedural terrain using dendritic fractals

--[[	A procedural function
	generates dendritic patterns
	locally computable; can be evaluated locally without context
	can be evaluated at different scales to add details
	can be computed procedurally using:
		L-systems
		diffusion limited aggregation
		erosion
]]
--[[	The function is controlled by parameters such as 
	the level of branching
	the degree of local smoothing
	random seeding and local disturbance parameters
	the range of the branching angles
]]
--[[	It is also controlled by a global control function that 
	defines the overall shape and can be used, for example, to initialize local minima
]]
--[[	The algorithm returns the distance to a tree structure which is 
	implicitly constructed on the fly
	requiring a small memory footprint
]]
--[[	The evaluation can be performed 
	in parallel for multiple points
	scales linearly with the number of cores
]]
--[[	The function applies to
	the generation of terrain heighfields with consistent river networks
	 drainage systems with small creeks converging to large rivers
]]
--[[	Procedural Scalar Function
		The procedural scalar function generates globally consistent branching patterns while still being locally computable. The model depends on a set of intuitive parameters, including a scalar function that controls the overall shape of the branching structure. The key idea consists of seeding pseudorandom seed positions on a regular cell lattice and linking them together to generate the underlying branching structure.
]]

Core concepts:
--[[	Synopsis: 
	 1. The procedural function f is controlled by a set of parameters and by a control function c. The value of f (p) is defined as the distance of the point p to the tree structure T. It can be evaluated in parallel for multiple points, and we show how it can generate consistent terrains with drainage areas. 2. T is constructed incrementally in n iterations.3. At each iteration k, the branches Bk are generated. 4. The final tree T is the union of all previously generated structures.
]]
--[[	The Procedural Function: 
	This procedural algorithm generates a two dimensional tree structure denoted by T. The input to this algorithm is a point p epsilon R^2 and the output is the real number value of the procedural function: f : R^2 → R. The value of the procedural function is the distance of the point p to the underlying branching structure T. An important property of this approach is that the procedural function does not explicitly generate the entire structure. It builds T only locally and computes the Euclidean distance:

	f (p) = d(p, T ). (1)

	An immediate benefit of this approach is that the function has a small memory footprint at the expense of being more computationally demanding. In facts, it needs to construct T on-the-fly at each evaluation.
]]
--[[	Control: 
	The function is controlled by a set of fixed parameters. The number of iterations n (n epsilon [1, 6] in this implementation) defines the amount of branching, where higher number brings more details. The seed of the pseudo random generator s is an integer value that guarantees that the generated structure will always remain the same for a given s. The limit of the random number generator 0 ≤ ε ≤ 0.5 defines the bias of the generated numbers and is further explained in Section 4. The displacement 0 ≤ ∆ ≤ 1 controls the overall curvature of the generated structure by defining the maximum displacement of segments. This parameter can be either a constant or can vary at every iteration and we denote it by ∆i ,i = 0, 1, . . . ,n − 1. The shape of T is affected by a control function c : R 2 → [0, 1], which can be thought of as an underlying environment that provides initial height-values at certain positions (Section 4.1). The control function can be either a constant, a procedural noise function, a user-defined pattern, or an interpolation of existing data such as an elevation map.
]]
--[[	Efficiency: 
	The evaluation at each point does not depend on other points and can be done in parallel in constant time. It is a CPUintensive algorithm with a small memory footprint, that implies low cache misses, and does not require any synchronization.
]]

Related  concepts:
--[[	Noise Fractals: 
		Terrains contain branching structures such as mountains ridges and river networks. Authors have used noise functions and fractal processes such as the fractional Brownian motion (fBm) to generate fractal-like landforms. Using additional noises allows for modeling the underlying structure locally, behaving like a function which guarantees that the noise is computed context-free at any position. This makes these algorithms attractive for real-time applications. Unfortunately, because of its lack of structuring landforms, fBm cannot generate hydrologically consistent terrains.
]]
--[[	L-systems: 
		The river network is generated using a grammar-like growth algorithm which computes nodes of a graph and their corresponding altitudes. Erosion: These algorithms can generate rivers and the combination of uplift and fluvial erosion is used to generate large scale terrains with dendritic river and ridge patterns.
]]
--[[	Scaling factors: 
		This idea is inspired by a hybrid of worley noise and circle packing where the distance mapping is influenced by a scaling factor to produce variable sized cells. A similar idea was considered for fBm noises. There the idea was to influence the noise gradients to reduce uniformity at larger octave scales. Try changing the values of the frequency and amplitude to understand how they behave. Using shaping functions, try changing the amplitude over time. Using shaping functions, try changing the frequency over time.
]]

Additional factors:
--[[	
]]
--[[	Erosion and Weathering
	Erosion and weathering are the processes in which the rocks are broken down into fine particles. Erosion is the displacement of solids by wind, water and ice. The eroded materials are displaced. The different types of erosion are water, wind, ice, thermal and gravity erosion. Weathering is the decomposition of rocks, soil and minerals by direct contact with the atmosphere. The weathered materials are not displaced. The different types of weathering include physical, chemical and biological weathering.
]]
--[[	• Hydraulic Erosion
		Hydraulic erosion is the process by which water transforms terrain over time. This is mostly caused by rainfall, but also by ocean waves hitting the shore and the flow of rivers. Figure 1 shows the considerable effects that a small stream has had on the rocky environment around it. Hydraulic erosion simulates changes to the terrain caused by flowing water dissolving material, transporting it and depositing it elsewhere.
]]
--[[	• Fluvial Erosion
		Fluvial erosion is the detachment of material of the river bed and the sides. It can be broken doen into three sub-categories: Sheet erosion describes erosion caused by runoff. Rill erosion describes erosion that takes place as runoff develops into discrete streams (rills). Gully erosion is the stage in which soil particles are transported through large channels. Erosion starts when the flow energy of the water exceeds the resistance of the material of the river bed and banks. Flow energy depends on depth of water and gradient and thus of stream velocity. Gorges, canyons, waterfalls, rapids, and river capture are examples of fluvial eroded landforms. There are four ways that a river erodes; hydraulic action, corrosion, corrosion and attrition.
		
		•	Hydraulic action from the force of the water wearing away the bed and bank of the river
		•	Corrosion, the chemical reaction between the water and the bed and bank of the river, wearing it away.
		•	Corrasion, or abrasion, where bedload in the river wears away its bed and bank.
		•	Attrition, where rocks in the water become smaller and rounder by hitting each other.
]]
--[[	• Coastal Erosion
		Coastal erosion is the breaking down and carrying away of materials by the sea. Deposition is when material carried by the sea is deposited or left behind on the coast. Coastal processes of erosion include hydraulic action, attrition, corrosion and solution. Landforms created by erosion include headlands and bays, caves, arches, stacks and stumps.
		
		•	Destructive waves. Waves that are very high in energy and are most powerful in stormy conditions. The swash is when a wave washes up onto the shoreline and the backwash is when the water from a wave retreats back into the sea. Destructive waves have stronger backwashes than swashes. This strong backwash pulls material away from the shoreline and into the sea resulting in erosion. 
		•	Constructive waves. Low energy waves that result in the build-up of material on the shoreline. Constructive waves are low energy and have stronger swashes than backwashes. This means that any material being carried by the sea is washed up and begins to build up along the coastline. The material that is deposited by constructive waves can most often be seen by the creation of beaches. Longshore drift is a method of coastal transport.
		•	Compression occurs in rocky areas when air enters into cracks in rock. This air is trapped in cracks by the rising tide, as waves crash against the rock the air inside the crack is rapidly compressed and decompressed causing cracks to spread and pieces of rock to break off. Compression is one of the main processes that result in the creation of caves.
]]
--[[	• Thermal Erosion
		Thermal erosion occurs where flowing water melts ground ice by the combined effects of heat conduction and convection, and then mechanically erodes newly released sediment. It often occurs on hillslopes during periods of snowmelt or heavy rainfall, and can lead to rapid gully development and persistent slope instability, particularly along ice wedges. In thaw slumps, intense thermal erosion during hot summer days can lead to intense dissection of massive icy sediments, producing a remarkable frozen badlands topography. Thermal erosion simulates material braking loose and sliding down slopes to pile up at the bottom. High water temperature, ice temperature, and discharge are shown to be the main contributors of thermal erosion, whereas high ice content in the soil is shown to slow down the thermal erosion process. Water discharge in permanent contact with permafrost banks creates a combination of thermal and mechanical erosion.
]]
--[[	• Tectonic Uplift
		Tectonic uplift is the raising of a geographical area as a consequence of plate tectonics. Both uplift and sinking can be due to plate tectonic movements, including mountain building, or the gravitational adjustment of the Earth's crust after material has been removed (resulting in uplift) or added (resulting in sinking) such as ice or sediment. The forces that drive Plate Tectonics include:
		
		•	Simulate uplift
			•Convection in the Mantle (heat driven)
			•Ridge push (gravitational force at the spreading ridges)
			•Slab pull (gravitational force in subduction zones)
]]
--[[	Erosion Simulations
		•	Create realistic terrains with erosion simulation.
		•	Use masks to drive and control the effects.

		 Erosion: Ultra-Fast, Realistic & Deterministic
		•	Use and combine the different algorithms: 
			•	Hydraulic erosion
			•	Rock erosion
			•	Mountain erosion
			•	Sedimental erosion
			•	Flow simulation
			•	Multi-erosion.

		User control: 
		•	Use masks to control where and how the simulation runs and achieve unique effects on different parts of the terrain.

		 Avoid Non-Realistic Alignment Effects
		•	Ensure algorithms generate erosion that doesn’t follow the world axes, providing results with more realism and diversity.

		Hydraulic erosion
		•	Create erosion effects by rainfall and river flows. Add realistic small-scale details to THE terrains.

		Rock erosion
		•	Simulate realistic rock erosion from the movements of sediment due to gravity.

		Mountain erosion
		•	Simulate the effect of fluvial erosion and rock weathering over a wide time span.

		Sedimental smoothing
		•	Simulate the effect of sedimental deposition due to the general weathering of the terrain.

		Flow simulation
		•	Simulate water movement on a landscape and generate different flow maps.

		Multi-erosion
		•	A ready-to-use component running a combination of the different algorithms to achieve stunning results.

		Thermal erosion
		•	Thermal erosion is similar to hydraulic erosion, with the addition of the possibility that the banks of the rivers collapse, giving rise to wider rivers.

		Multi-scale erosion
		•	Multi-scale erosion of the terrain at different scales. It can erode the terrain more significantly than the Hydraulic or Thermal erosion nodes.

		Flow map 2D
		•	A vector map where the direction and norm of each vector corresponds to the direction and the quantity of the water flow.
]]
		
		
		