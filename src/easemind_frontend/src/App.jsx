import { useState } from 'react';
import { easemind_backend } from 'declarations/easemind_backend';


function App() {
  const [greeting, setGreeting] = useState('');
  const [createUserMessage, setCreateUserMessage] = useState('');

  function handleAlex(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    easemind_backend.greet(name).then((greeting) => {
      setGreeting(greeting);
    });
    return false;
  }

  function createUser(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    const payload = {
      id: '',
      nickname: name,
      achievementsId: '',
      points: 0.0,
    };
    easemind_backend.createUser(payload).then((user) => {
      setCreateUserMessage(user);
      console.log(user)
    });
    return false;
  }

  return (
    <main>
      <img src="/logo2.svg" alt="DFINITY logo" />
      <br />
      <br />
      {/* <form action="#" onSubmit={handleAlex}>
        <label htmlFor="name">Enter your name: &nbsp;</label>
        <input id="name" alt="Name" type="text" />
        <button type="submit">Click Me!</button>
      </form>
      <section id="greeting">{greeting}</section> */}

      <form action="#" onSubmit={createUser}>
        <label htmlFor="name">Enter your name: &nbsp;</label>
        <input id="name" alt="Name" type="text" />
        <button type="submit">Click Me!</button>
      </form>
      <section id="greeting">{createUserMessage}</section>
    </main>
  );
}

export default App;