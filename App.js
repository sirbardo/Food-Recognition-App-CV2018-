import React from 'react';
import { StyleSheet, Text, View, Image, Platform} from 'react-native';

export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text>Ciao!</Text>
        <Text>Pene.</Text>
        <Image 
        style={{width:100, height:100}}
        source={{uri: 'https://facebook.github.io/react-native/docs/assets/favicon.png'}}></Image>
        <Text>Shake your phone to open the developer menu.</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
