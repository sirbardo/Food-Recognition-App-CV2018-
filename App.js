import React, { Component } from 'react';
import {
  AppRegistry,
  Dimensions,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Image,
  ImageBackground,
  StatusBar,
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
        <View style={{ flex: 1, flexDirection: 'row', justifyContent: 'center', }}>
          <TouchableOpacity
            onPress={this.takePicture.bind(this)}
            style={styles.capture}
          >
            <Text>What's this food!?</Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={this.openGallery.bind(this)}
            style={styles.gallery}
          >
            <Text>G</Text>
          </TouchableOpacity>
        </View>
      </RNCamera>
    );
  }

  renderImage() {
    return (
      

      <View style={styles.imageContainer}>
        <ImageBackground 
          source={{uri: this.state.path}}
          style={styles.image}>
          <Text
            style={styles.predictionText}
          >
          {this.state.predictionToShow}
          </Text>

          <TouchableOpacity
            onPress={() => this.setState({ path: null })}
            style={styles.cancelButton}
          >
            <Text>X</Text>
          </TouchableOpacity>

        </ImageBackground>
        
      </View>
    );
  }
  
  render() {
    return (
      <View style={styles.container}>
      <StatusBar
        barStyle="light-content"
      />
        {this.state.path ? this.renderImage() : this.renderCamera()}
      </View>
    );
  }

  openGallery = function (){
    var options = null
    var ImagePicker = require('react-native-image-picker');
    ImagePicker.launchImageLibrary(options, (response) => {
      console.log('Response = ', response);
    
      if (response.didCancel) {
        console.log('User cancelled image picker');
      }
      else if (response.error) {
        console.log('ImagePicker Error: ', response.error);
      }
      else if (response.customButton) {
        console.log('User tapped custom button: ', response.customButton);
      }
      else {
        let source = { uri: response.uri };
    
        const PredictionManager = NativeModules.PredictionManager;
        prediction = PredictionManager.predict(response.data, (predictionString) => {
          this.setState(() => {return {predictionToShow: predictionString.prediction}});
          this.setState(() => {return{path: source.uri}});
      });
      }
    });

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
    alignItems: 'stretch',
    justifyContent: 'center',
  },
  image: {
    flexGrow:1,
    height:null,
    width:null,
    alignItems: 'center',
    justifyContent:'center',
  },
  cancelButton: {
    position: 'absolute',
    flex: 0,
    backgroundColor: '#fff',
    borderRadius: 100,
    padding: 15,
    paddingHorizontal: 20,
    alignSelf: 'center',
    margin: 20,
    bottom: 5
  },
  predictionText: {
    textAlign: 'center',
    color: 'rgba(255,255,255,.8)',
    fontSize: 80,
    fontWeight: 'bold',
    transform: [{ rotate: '-45deg'}]
    
  },
  capture: {
    flex: 0,
    backgroundColor: '#fff',
    borderRadius: 5,
    padding: 15,
    paddingHorizontal: 20,
    alignSelf: 'center',
    margin: 20,
    position: 'absolute',
    bottom: 5
  },
  gallery: {
    flex: 2,
    backgroundColor: '#fff',
    borderRadius: 100,
    padding: 15,
    paddingHorizontal: 20,
    margin: 20,
    position: 'absolute',
    bottom: 5,
    right: 80
  }
});

