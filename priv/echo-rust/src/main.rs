extern crate erl_ext;
use erl_ext::{Encoder, Decoder, Error};
use std::io;

fn fuzz<R : io::Read>(mut encoder: Encoder, mut decoder: Decoder<R>) -> Result<(), Error> {
    decoder.read_prelude()?;
    let term = decoder.decode_term()?;
    encoder.write_prelude()?;
    encoder.encode_term(term)?;
    encoder.flush()?;

    Ok(())
}

fn main() {
    let utf8_atoms = true;
    let small_atoms = true;
    let fair_new_fun = true;

    let mut output = io::stdout();
    let mut input = io::stdin();
    let encoder = Encoder::new(&mut output, utf8_atoms, small_atoms, fair_new_fun);
    let decoder = Decoder::new(&mut input);

    match fuzz(encoder, decoder) {
        Ok(()) => (),
        Err(e) => eprintln!("Error: {:?}", e)
    }
}
