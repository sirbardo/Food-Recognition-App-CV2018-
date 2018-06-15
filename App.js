import React, { Component } from 'react';
import {
  AppRegistry,
  Dimensions,
  StyleSheet,
  Text,
  TouchableOpacity,
  View
} from 'react-native';
import { RNCamera } from 'react-native-camera';
import {NativeModules} from 'react-native';

export default class App extends React.Component {
  

  constructor(){
    super();

    this.state = { predictionToShow: 'Sample'}

  }
  
  render() {
    return (
      <View style={styles.container}>
        <RNCamera
            ref={ref => {
              this.camera = ref;
            }}
            style = {styles.preview}
            type={RNCamera.Constants.Type.back}
            flashMode={RNCamera.Constants.FlashMode.on}
            permissionDialogTitle={'Permission to use camera'}
            permissionDialogMessage={'We need your permission to use your camera phone'}
        />
        <Text style={{color: 'white'}}>
            {this.state.predictionToShow}
        </Text>
        <View style={{ flex: 0, flexDirection: 'row', justifyContent: 'center', }}>
          <TouchableOpacity
            onPress={this.takePicture.bind(this)}
            style={styles.capture}
          >
            <Text>What's this food!?</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  takePicture = async function() {
    if (this.camera){
      const options = { quality: 0.5, base64: true , flashMode: 'off'};
      const data = await this.camera.takePictureAsync(options)
      const PredictionManager = NativeModules.PredictionManager;
      prediction = PredictionManager.predict(data.base64, (predictionString) => {
        this.setState(() => {return {predictionToShow: predictionString.prediction}});
    });
    }
  };  
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'black'
  },
  preview: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center'
  },
  capture: {
    flex: 0,
    backgroundColor: '#fff',
    borderRadius: 5,
    padding: 15,
    paddingHorizontal: 20,
    alignSelf: 'center',
    margin: 20
  }
});

