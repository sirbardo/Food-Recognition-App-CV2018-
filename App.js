import React, { Component, } from 'react';
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
import {Header} from 'react-native-elements';


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
        <View style={{ flex: 0, flexDirection: 'row', justifyContent: 'center', alignSelf: 'stretch', backgroundColor: 'blue'}}>
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
          source={{uri: 'data:image/png;base64,'+this.state.path}}
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
      <Header 
        backgroundColor='#21B6A8'
        centerComponent={{ text: 'Food Recognition', style: { color: '#fff', fontSize: 20} }}
      />


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
    
        const PredictionManager = NativeModules.PredictionManager;
        prediction = PredictionManager.predict(response.data, (predictionString) => {
          this.setState(() => {return {predictionToShow: predictionString.prediction}});
          this.setState(() => {return{path: predictionString.bboxImage}});
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
        this.setState(() => {return{path: predictionString.bboxImage}});
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
    backgroundColor: '#fff',
    borderRadius: 100,
    padding: 15,
    paddingHorizontal: 20,
    margin: 20,
    bottom: 5
  },
  predictionText: {
    textAlign: 'center',
    color: 'rgba(255,255,255,.8)',
    fontSize: 80,
    fontWeight: 'bold',
    transform: [{ rotate: '-45deg'}],
    borderColor: 'black',
    textShadowColor: 'rgba(0, 0, 0, 0.8)',
    textShadowOffset: {width: -1, height: 1},
    textShadowRadius: 10
    
  },
  capture: {
    backgroundColor: '#fff',
    borderRadius: 5,
    padding: 15,
    paddingHorizontal: 20,
    margin: 20,
    position: 'absolute',
    bottom: 5
  },
  gallery: {
    backgroundColor: '#fff',
    borderRadius: 100,
    padding: 15,
    paddingHorizontal: 20,
    margin: 20,
    position: 'absolute',
    bottom: 5,
    left: 0
  }
});

