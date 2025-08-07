


/* global tempBtVector */

function add_child(threeParent, threeChild) {
    if (typeof threeParent.userData.children == 'undefined' || threeParent.userData.children === null) {
        threeParent.userData.children = new Array();
        //alert('aaa');
    }
    threeParent.userData.children[threeChild.userData.name] = threeChild;
    //alert(threeParent.userData.name + ' ---> ' +  threeChild.userData.name);
   // console.log(threeParent.userData.children);
}


function delete_child(threeParent, threeChild) {
    threeParent.userData.children[threeChild.userData.name]=null;
    delete threeParent.userData.children[threeChild.userData.name];
}





function move_delta_linear(threeObject, delta_x, delta_y, delta_z) {

    threeObject.position.x += delta_x;
    threeObject.position.y += delta_y;
    threeObject.position.z += delta_z;


    // verificar se é só igual
    threeObject.rotation.x += 0;
    threeObject.rotation.y += 0;
    threeObject.rotation.z += 0;

    var objPhys = threeObject.userData.physicsBody;
    var tr = objPhys.getWorldTransform();
   // tr.setOrigin(new Ammo.btVector3(threeObject.position.x, threeObject.position.y, threeObject.position.z));
   
    tempBtVector.setValue(threeObject.position.x,threeObject.position.y,threeObject.position.z);
    
    tr.setOrigin(tempBtVector);
 //   tr.set

    var children = threeObject.userData.children;
    if (typeof children !== 'undefined' && children !== null) {
        for (var threeName in children)
        {
            if (children.hasOwnProperty(threeName)) 
              //alert("Key is " + threeName + ", value is " + children[threeName]);
                move_delta_linear(children[threeName], delta_x, delta_y, delta_z);
        }
    }
}



function move_abs_linear(threeObject, abs_x, abs_y, abs_z) {
    var delta_x = abs_x - threeObject.position.x;
    var delta_y = abs_y - threeObject.position.y;
    var delta_z = abs_z - threeObject.position.z;
    move_delta_linear(threeObject, delta_x, delta_y, delta_z);
}


function toBinary(val) {
    result = "";
    for (i = 7 ; i >= 0; i--) {
        if ((val & (1 << i)) != 0)
            result += "1";
        else
            result += "0";
        if (i == 4)
            result += " ";
    }
    return (result);
}




function include_html(idFile) {
    $(function () {
        $("#"+idFile).load(idFile+".html#"+ (Math.random()*1000) );
    });
}