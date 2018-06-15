import React, { Component } from 'react';
import {
  AppRegistry,
  Dimensions,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Image
} from 'react-native';
import { RNCamera } from 'react-native-camera';
import {NativeModules} from 'react-native';


export default class App extends React.Component {
  

  constructor(){
    super();

    this.state = {path: null, predictionToShow: 'Sample',}

  }

  renderCamera() {
    return (
      <RNCamera
        ref={(cam) => {
          this.camera = cam;
        }}
        style={styles.preview}
        type={RNCamera.Constants.Type.back}
        flashMode={RNCamera.Constants.FlashMode.auto}
        permissionDialogTitle={'Permission to use camera'}
        permissionDialogMessage={'We need your permission to use your camera phone'}
      >
        <View style={{ flex: 0, flexDirection: 'row', justifyContent: 'center', }}>
          <TouchableOpacity
            onPress={this.takePicture.bind(this)}
            style={styles.capture}
          >
            <Text>What's this food!?</Text>
          </TouchableOpacity>
        </View>
      </RNCamera>
    );
  }

  renderImage() {
    return (
      

      <View style={styles.imageContainer}>
        <Image 
          source={{uri: this.state.path}}
          style={styles.canvas} 
        />
        <Text
          style={styles.cancel}
          onPress={() => this.setState({ path: null })}
        >Cancel
        </Text>
      </View>
    );
  }
  
  render() {
    return (
      <View style={styles.container}>
        {this.state.path ? this.renderImage() : this.renderCamera()}
      </View>
    );
  }

  takePicture = async function() {
    if (this.camera){
      const options = { quality: 0.5, base64: true};
      const data = await this.camera.takePictureAsync(options)
      const PredictionManager = NativeModules.PredictionManager;
      prediction = PredictionManager.predict(data.base64, (predictionString) => {
        this.setState(() => {return {predictionToShow: predictionString.prediction}});
        this.setState(() => {return{path: data.uri}});
    });
    }
  };  
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'white'
  },
  preview: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
    height: Dimensions.get('window').height,
    width: Dimensions.get('window').width

  },
  imageContainer: {
    flex: 1,
    alignItems: 'stretch'
  },
  canvas: {
    flex: 1
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

