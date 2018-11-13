// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("game:space_invaders", {})
let frame = document.querySelector("#frame")
let start = document.querySelector("#start-game")
let reset = document.querySelector("#reset-game")

var width = 600, height = 600

var elem = document.getElementById('frame');
var params = { width: width, height: height };
var two = new Two(params).appendTo(elem);



start.addEventListener("click", event => {
  channel.push("start_game", {name: "game_one"})
})

reset.addEventListener("click", event => {
  channel.push("reset_game", {name: "game_one"})
})

document.addEventListener("keyup", event => {
  if(event.code == "Space"){
    channel.push("fire", {name: "game_one"})
  }else if (event.code == "ArrowLeft") {
    channel.push("move_player", {name: "game_one", dir: -1})
  }else if (event.code == "ArrowRight") {
    channel.push("move_player", {name: "game_one", dir: 1})
  }
})

channel.on("start_game", payload => {

})


channel.on("state", payload => {
  two.clear();
  two.makeText("Score: " + payload.state.points, 40, 10)


  two.makeText("Credits: " + payload.state.credits, 400, 10)
  console.log(payload.state.credits)
  if (payload.state.credits===0){
    two.makeText("GAME OVER", 200, 150)
    two.update();
    return
  }

  payload.state.board.forEach(element => {
    if(element.visible){

      if(element.type==="invader_ship"){
        var rect = two.makeRectangle(40 * (element.y+1), 40 * (element.x+1), 20, 20);
        rect.fill = 'rgb(0, 200, 255)';
        rect.opacity = 0.75;
        rect.noStroke();
      }else if(element.type==="player_ship") {
        var triangle = two.makePolygon(40 * (element.y+1), 40 * (element.x+1), 20, 3);
        triangle.fill = 'rgb(0, 255, 255)';
        triangle.opacity = 0.75;
        triangle.noStroke();
      } else if(element.type==="bullet"){
        var circle = two.makeCircle(40 * (element.y+1), 40 * (element.x+1), 10);
        circle.fill = 'red';
        circle.opacity = 0.75;
        circle.noStroke();
      } else if(element.type==="invader_bullet"){
        var circle = two.makeCircle(40 * (element.y+1), 40 * (element.x+1), 10);
        circle.fill = 'green';
        circle.opacity = 0.75;
        circle.noStroke();
      }
    }
    // }else{
    //   var rect = two.makeRectangle(40 * (element.y+1), 40 * (element.x+1), 20, 20);
    //   rect.fill = 'rgb(220, 200, 255)';
    //   rect.opacity = 0.75;
    // }

  });
  two.update();

})


channel.join()
  .receive("ok", resp => {console.log("Joined successfully", resp)})
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
