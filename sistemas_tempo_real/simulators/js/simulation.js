// JavaScript source code


function initDrag() {
    //drag controlls
    var dragControls = new THREE.DragControls(objects, camera, renderer.domElement);
    dragControls.addEventListener('dragstart', function (event) {
        controls.enabled = false;
    });
    dragControls.addEventListener('dragend', function (event) {
        controls.enabled = true;
    });
    /*var info = document.createElement( 'div' );
     info.style.position = 'absolute';
     info.style.top = '10px';
     info.style.width = '100%';
     info.style.textAlign = 'center';
     info.innerHTML = '<a href="http://threejs.org" target="_blank" rel="noopener">three.js</a> webgl - draggable cubes';
     container.appendChild( info );
     */
}


function initPhysics() {

    // Physics configuration
    collisionConfiguration = new Ammo.btDefaultCollisionConfiguration();
    dispatcher = new Ammo.btCollisionDispatcher(collisionConfiguration);
    broadphase = new Ammo.btDbvtBroadphase();
    solver = new Ammo.btSequentialImpulseConstraintSolver();
    physicsWorld = new Ammo.btDiscreteDynamicsWorld(dispatcher, broadphase, solver, collisionConfiguration);
    physicsWorld.setGravity(new Ammo.btVector3(0, -gravityConstant, 0));

}


function createBox(name, px, py, pz, rx, ry, rz, sx, sy, sz, mass, _colour, isKeen) {
    threeObject = new THREE.Mesh(new THREE.BoxGeometry(sx, sy, sz, 1, 1, 1), new THREE.MeshPhongMaterial({ color: _colour }));
    shape = new Ammo.btBoxShape(new Ammo.btVector3(sx * 0.5, sy * 0.5, sz * 0.5));
    shape.setMargin(margin);
    threeObject.position.set(px, py, pz);

    threeObject.rotateX(rx);
    threeObject.rotateY(ry);
    threeObject.rotateZ(rz);



    threeObjects[name] = threeObject;
    threeObject.userData.name = name;

    createRigidSolid(threeObject, shape, mass, isKeen);
    return threeObject;

}



function createCylinder(name, px, py, pz, rx, ry, rz, radius, height, mass, _colour, isKeen) {



    threeObject = new THREE.Mesh(new THREE.CylinderGeometry(radius, radius, height, 20, 1), new THREE.MeshPhongMaterial({ color: _colour }));
    shape = new Ammo.btCylinderShape(new Ammo.btVector3(radius, height * 0.5, radius));
    shape.setMargin(margin);
    threeObject.position.set(px, py, pz);

    threeObject.rotateX(rx);
    threeObject.rotateY(ry);
    threeObject.rotateZ(rz);

    //cylAxis = new THREE.AxisHelper(100);
    //threeObject.add(cylAxis);


    threeObjects[name] = threeObject;
    threeObject.userData.name = name;

    createRigidSolid(threeObject, shape, mass, isKeen);

    threeObject.userData.physicsBody.setLinearVelocity(new Ammo.btVector3(0, 1, 0));

    return threeObject;

}


function createRigidSolid(threeObject, shape, mass, isKeen) {

    objects.push(threeObject);


    localInertia = new Ammo.btVector3(0, 0, 0);
    shape.calculateLocalInertia(mass, localInertia);
    transform = new Ammo.btTransform();
    transform.setIdentity();
    pos = threeObject.position;
    //rot = threeObject.rotation;
    transform.setOrigin(new Ammo.btVector3(pos.x, pos.y, pos.z));


    // worldQuaternion = new THREE.Quaternion();
    // worldQuaternion threeObject.getWorldQuaternion(  );
    q = threeObject.quaternion;


    transform.setRotation(new Ammo.btQuaternion(q.x, q.y, q.z, q.w));


    motionState = new Ammo.btDefaultMotionState(transform);
    rbInfo = new Ammo.btRigidBodyConstructionInfo(mass, motionState, shape, localInertia);
    body = new Ammo.btRigidBody(rbInfo);

    //body.setFriction(1);
    // body.setDamping(1);
    //body.setRestitution(0);

    body.setActivationState(4);

    threeObject.userData.physicsBody = body;
    threeObject.receiveShadow = true;
    threeObject.castShadow = true;




    //threeObjects.push(threeObject);
    if (isKeen === false) {
        rigidBodies.push(threeObject);
    }
    physicsWorld.addRigidBody(body);
}


function initInput() {
    window.addEventListener('mousedown', function (event) {
        mouseCoords.set(
            (event.clientX / window.innerWidth) * 2 - 1,
            -(event.clientY / window.innerHeight) * 2 + 1
        );
        raycaster.setFromCamera(mouseCoords, camera);
        // Creates a ball and throws it
        var ballMass = 35;
        var ballRadius = 2;
        var ball = new THREE.Mesh(new THREE.SphereGeometry(ballRadius, 14, 10), ballMaterial);
        ball.castShadow = true;
        ball.receiveShadow = true;
        var ballShape = new Ammo.btSphereShape(ballRadius);
        ballShape.setMargin(margin);
        pos.copy(raycaster.ray.direction);
        pos.add(raycaster.ray.origin);
        quat.set(0, 0, 0, 1);
        var ballBody = createRigidBody(ball, ballShape, ballMass, pos, quat);
        pos.copy(raycaster.ray.direction);
        pos.multiplyScalar(200);
        ballBody.setLinearVelocity(new Ammo.btVector3(pos.x, pos.y, pos.z));
    }, false);
}


function createObjectMaterial() {
    var c = Math.floor(Math.random() * (1 << 24));
    return new THREE.MeshPhongMaterial({ color: c });
}


function createRigidBody(object, physicsShape, mass, pos, quat, vel, angVel) {

    if (pos) {
        object.position.copy(pos);
    } else {
        pos = object.position;
    }
    if (quat) {
        object.quaternion.copy(quat);
    } else {
        quat = object.quaternion;
    }

    var transform = new Ammo.btTransform();
    transform.setIdentity();
    transform.setOrigin(new Ammo.btVector3(pos.x, pos.y, pos.z));
    transform.setRotation(new Ammo.btQuaternion(quat.x, quat.y, quat.z, quat.w));
    var motionState = new Ammo.btDefaultMotionState(transform);

    var localInertia = new Ammo.btVector3(0, 0, 0);
    physicsShape.calculateLocalInertia(mass, localInertia);

    var rbInfo = new Ammo.btRigidBodyConstructionInfo(mass, motionState, physicsShape, localInertia);
    var body = new Ammo.btRigidBody(rbInfo);

    body.setFriction(0.5);

    if (vel) {
        body.setLinearVelocity(new Ammo.btVector3(vel.x, vel.y, vel.z));
    }
    if (angVel) {
        body.setAngularVelocity(new Ammo.btVector3(angVel.x, angVel.y, angVel.z));
    }

    object.userData.physicsBody = body;
    object.userData.collided = false;

    scene.add(object);

    if (mass > 0) {
        rigidBodies.push(object);

        // Disable deactivation
        body.setActivationState(4);
    }

    physicsWorld.addRigidBody(body);

    return body;
}


function createParalellepipedWithPhysics(sx, sy, sz, mass, pos, quat, material) {

    var object = new THREE.Mesh(new THREE.BoxGeometry(sx, sy, sz, 1, 1, 1), material);
    var shape = new Ammo.btBoxShape(new Ammo.btVector3(sx * 0.5, sy * 0.5, sz * 0.5));
    shape.setMargin(margin);

    createRigidBody(object, shape, mass, pos, quat);

    return object;

}



function onWindowResize() {

    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);

}



function updatePhysics(deltaTime) {

    // Step world
    physicsWorld.stepSimulation(deltaTime, 10);

    // Update rigid bodies


    //if it isn't at inside and outside, disable physics 
    if (getBitValue(PORTS[0], 3) && getBitValue(PORTS[0], 5))
        if (delta_x != 0 || delta_y != 0)
            return;


    for (var i = 0, il = rigidBodies.length; i < il; i++) {
        var objThree = rigidBodies[i];
        var objPhys = objThree.userData.physicsBody;
        var ms = objPhys.getMotionState();
        if (ms) {
            ms.getWorldTransform(transformAux1);

            var p = transformAux1.getOrigin();
            var q = transformAux1.getRotation();
            objThree.position.set(p.x(), p.y(), p.z());
            // objThree.quaternion.set(q.x(), q.y(), q.z(), q.w());

            objThree.userData.collided = false;


        }
    }

}


function update_sensor_color(threeObject, state_value, activation_level, active_color, inactive_color) {
    if (activation_level === 0) {
        if (state_value === 0)
            threeObject.material.color.setHex(active_color);
        else
            threeObject.material.color.setHex(inactive_color);
    }
    if (activation_level === 1) {
        if (state_value !== 0)
            threeObject.material.color.setHex(active_color);
        else
            threeObject.material.color.setHex(inactive_color);
    }


}



function startWorker() {
    if (typeof (Worker) !== "undefined") {
        if (typeof (the_worker) === "undefined") {
            the_worker = new Worker("js/theworker.js");
        }
        the_worker.onmessage = worker_event;
        /*** fim post data *****/
    } else {
        //document.getElementById("result").innerHTML = "Sorry! No Web Worker support.";
        console.log("Sorry! No Web Worker support.");
    }
}



    

