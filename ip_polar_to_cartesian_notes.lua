    Conversion between Polar and Cartesian Coordinates

    Conversion from cartesian to polar coordinates: (2D)
    Cartesian [x, y]  Polar [r, φ]

        φ = arctan(y/x)
            for x > 0
        φ = π/2
            for x = 0 and y > 0
        φ = π + arctan(y/x)
            for x < 0
        φ = 3π/2
            for x = 0 and y < 0

    Conversion from polar to cartesian coordinates:
    Polar [r, φ]  Cartesian [x, y]

        x = r * cos φ
        y = r * sin φ

Conversion from cartesian to polar coordinates: (3D) 
Cartesian [x,y,z] Polar [r,θ,φ]

    rho = sqrt(x^2+y^2+z^2)
    theta = arctan((sqrt (x^2+y^2)/z) = arccos (z/(sqrt (x^2+y^2+z^2))) 
    phi = arctan(y/x) = arccos(x/(sqrt(x^2+y^2))) = arcsin(y/(sqrt(x^2+y^2)))

    ∂ (rho ,theta ,phi) / ∂ (x,y,z) =  
        [ 
            x / rho                                                     y / rho                                                     z / rho 
            xz / (rho ^2 (sqrt(x^2+y^2)    yz/ rho ^2 (sqrt(x^2+y^2)        -(sqrt(x^2+y^2) / rho ^2
            -y / (x^2+y^2)                                  x / (x^2+y^2)                                     0
        ]
    
        How do you pronounce ∂? (∂ - the partial derivative symbol, sometimes mistaken for a lowercase Greek letter Delta.)
        The symbol is variously referred to as "partial", "curly d", "rounded d", "curved d", "dabba", or "Jacobi's delta", or as "del" (but this name is also used for the "nabla" symbol ∇). It may also be pronounced simply "dee", "partial dee", "doh", or "die".
            See also the article on atan2 for how to elegantly handle some edge cases.

        So for the element:
            ∂ rho ∂ theta ∂ phi = det ( ∂ (rho,theta,phi) / ∂ (x,y,z) ) dx dy dz =(1 / (sqrt(x^2+y^2) (sqrt(x^2+y^2+z^2))) dx dy dz

How do you define a matrix in programming?
    A matrix is a grid used to store or display data in a structured format. It is often used synonymously with a table, which contains horizontal rows and vertical columns. While the terms "matrix" and "table" can be used interchangeably, matrixes (or matrices) are considered more flexible than tables.Jul 2, 2013


How to access the value at a given coordinate?
    The difference from generating noise is that it's not clear where the values to sample come from. With internally generated noise, there is something to sample, but in the spheres of the working scripts only the axis gradients have been sampled. The methods used in the script are more detailed than the online versions, so test them to find out what effect each bit of code has on the result.

function polar_to_cartesian(radius, a_phi, a_theta)
 x = radius * math.sin(a_phi) * math.cos(a_theta)
 y = radius * math.sin(a_phi) * math.sin(a_theta)
 z = radius * math.cos(a_theta)
 -- how to get v from x, y, z? (if v is the value sampled at those coordinates)
 return x, y, z
end

function cartesian_to_polar(x,y,z)
    local r = math.sqrt((x * x) + (y * y) + (z * z))
    local phi = math.atan(y/x)
        -- math.cos(phi) = x / (math.sqrt((x * x) + (y * y)))  
        -- math.sin(phi) = y / (math.sqrt((x * x) + (y * y)))  
        -- math.tan(phi) = y / x
            -- which is used when?
    local theta = math.atan((math.sqrt (x^2+y^2)/z)
        -- math.cos(theta) = z / radius = z / math.sqrt((x * x) + (y * y) + (z * z))
            -- if the second equation is equivalent, do you skip straight to the second?
    return r, phi, theta
end


Transformation coordinates Cartesian (x,y,z) → Spherical (r,θ,φ)
r=(√x^2+y^2+z^2)
θ=tan^−1 (y/x)
φ=tan^−1 (√x^2+y^2)/z 
    tan x^−1, sometimes interpreted as (tan(x))−1 = 1tan(x) = cot(x) or cotangent of x, the multiplicative inverse (or reciprocal) of the trigonometric function tangent (see above for ambiguity)
    Tan-1, TAN-1, tan-1, or tan^−1 may refer to:
        tan^−1y = tan^−1(x), sometimes interpreted as arctan(x) or arctangent of x, the compositional inverse of the trigonometric function tangent (see below for ambiguity)
        tan−1x = tan−1(x), sometimes interpreted as (tan(x))−1 = 1/tan(x) = cot(x) or cotangent of x, the multiplicative inverse (or reciprocal) of the trigonometric function tangent (see above for ambiguity)
        tan x−1, sometimes interpreted as tan(x−1) = tan(1/x), the tangent of the multiplicative inverse (or reciprocal) of x (see below for ambiguity)
        tan x−1, sometimes interpreted as (tan(x))−1 = 1/tan(x) = cot(x) or cotangent of x, the multiplicative inverse (or reciprocal) of the trigonometric function tangent (see above for ambiguity)[citation needed]
    Because of ambiguity, the notation arctan(x) or (tan(x))−1, is recommended.function p2c(r,theta) local cart={}
     ptheta=theta*360
     x=r*cos(ptheta)
     y=r*sin(ptheta)
     return  x, y
end

it's fairly straightforward to take polar coordinates by performing the transformation back to rectangular coordinates within the function(r*cos(theta),r*sin(theta)).

Cartesian coordinates can be calculated from Polar coordinates like
 x = r • cos(θ)
 y = r • sin(θ)
 -- requires r (radius) and θ (angle)
 -- may require angle = angle * math.pi / 180

Spherical Coordinates
In the Cartesian coordinate system, the location of a point in space is described using an ordered triple in which each coordinate represents a distance. In the cylindrical coordinate system, location of a point in space is described using two distances  (r  and  z)  and an angle measure  (θ) . In the spherical coordinate system, we again use an ordered triple to describe the location of a point in space. In this case, the triple describes one distance and two angles. Spherical coordinates make it simple to describe a sphere, just as cylindrical coordinates make it easy to describe a cylinder. Grid lines for spherical coordinates are based on angle measures, like those for polar coordinates.

Definition: spherical coordinate system

In the spherical coordinate system, a point  P  in space (Figure  12.7.9 ) is represented by the ordered triple  (ρ, θ, φ)  where

ρ  (the Greek letter rho) is the distance between  P  and the origin  (ρ≠0); 
θ  (the Greek letter theta) is the same angle used to describe the location in cylindrical coordinates;
φ  (the Greek letter phi) is the angle formed by the positive  z -axis and line segment  OP¯ , where  O  is the origin and  0 ≤ φ ≤ π.

--- Transform 2D polar coordinates to 2D cartesian coordinates
-- @param polar_phi angle of the polar coordinate
-- @param polar_dist distance of the polar coordinate
-- @return two floats, x and y components of the cartesian coordinate (in that order)
function math.polar2cart2d(polar_phi, polar_dist)
    return polar_dist * math.cos(polar_phi), polar_dist * math.sin(polar_phi);
end

To convert a point from spherical coordinates to Cartesian coordinates, use equations: 
 x = ρ • sinφ • cosθ
 y = ρ • sinφ • sinθ 
 z = ρ • cosφ
 -- rho (radius), 
 -- phi (the angle to the z axis in spherical coordinates), 
 -- theta (the angle to the x axis in the xy-plane in spherical or cylindrical coordinates)
 -- • denotes multiplication
 
To convert a point from Cartesian coordinates to spherical coordinates, use equations: 
 ρ^2 = x^2 + y^2 + z^2 
 tanθ = y / x 
 φ = arccos(z / √ x^2 + y^2 + z^2).



