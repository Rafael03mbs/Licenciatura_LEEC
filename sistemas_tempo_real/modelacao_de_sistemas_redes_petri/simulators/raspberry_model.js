

    var moveLeftVariable = "false";
    var moveRightVariable = "false"; 

    function buttonClickLeft() {
      if (moveLeftVariable === "false") {
        moveLeftVariable = "true";
      } else {
        moveLeftVariable = "false";
      }
      console.log("moveLeftVariable: " + moveLeftVariable);
    }
    function buttonClickRight() {
      if (moveRightVariable === "false") {
        moveRightVariable = "true";
      } else {
        moveRightVariable = "false";
      }
      console.log("moveRightVariable: " + moveRightVariable);
    }


    var mutexLeft = false;
    var mutexRight = false;

    var pinValues = [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    ];


    function callActuators() {

      if (mutexLeft === false) {
        mutexLeft = true;
        fetch('/moveLeft')
          .then(response => {
            if (!response.ok) {
              throw new Error('Network response was not ok');
            }
            return response.text(); // Return the response text
          })
          .then(data => {
            moveLeftVariable = data;
            mutexLeft = false;
            //console.log('Response from moveLeft:', data);
          })
          .catch(error => {
            mutexLeft = false;
            console.error('Error calling moveLeft:', error);
          });
      }

      if (mutexRight === false) {
        mutexRight = true;
        fetch('/moveRight')
          .then(response => {
            if (!response.ok) {
              throw new Error('Network response was not ok');
            }
            return response.text(); // Return the response text
          })
          .then(data => {
            moveRightVariable = data;
            mutexRight = false;
            //console.log('Response from moveLeft:', data);
          })
          .catch(error => {
            mutexRight = false;
            console.error('Error calling moveLeft:', error);
          });
      }
    }



    var sendPinValueMutex = false;
    function postPinValue(GPIO_ID, Value) {
      //if (!sendPinValueMutex) {
        sendPinValueMutex = true;
        fetch('/newPinFromSimulator', {
          method: 'POST', // Specify the HTTP method
          headers: {
            'Content-Type': 'application/json' // Specify the content type
          },
          body: JSON.stringify({ GPIO_ID: GPIO_ID, Value: Value }) // Convert data to JSON string
        })
          .then(response => {
            if (!response.ok) {
              throw new Error('Network response was not ok');
            }
            return response.text(); // Return the response text
          })
          .then(data => {
            console.log(data);
            sendPinValueMutex = false;
            // console.log('Response from moveLeft:', data);
          })
          .catch(error => {
            sendPinValueMutex = false;
            console.error('Error calling sendPinValue:', error);
          });
      //}
    }


    var isFetching = false;
    function fetchData() {
      if (!isFetching) {
        isFetching = true;
        fetch('/getBitValues')
          .then(response => response.json())
          .then(data => {
            pinValues = data;
            isFetching = false;
          })
          .catch(error => {
            console.error('Error fetching data:', error);
            isFetching = false;
          });
      }
    }


    /*
    window.addEventListener('load', function() {
    // Call fetchData every 1ms
        setInterval(fetchData, 1);
    });

    */